class PaperRecommender
  class Error < StandardError; end

  BATCH_SIZE = 80
  public_constant :BATCH_SIZE

  def initialize(user)
    @user = user
  end

  def refresh!
    raise Error, 'Follow at least one category first.' if user.categories.none?

    client = recommendation_client(user.llm_provider)

    token = claim_lease!
    begin
      process_batch(client)
    ensure
      User.where(id: user.id, recommendation_processing_started_at: token).
        update_all(recommendation_processing_started_at: nil)
    end
  end

  def pending_count
    pending_papers.count
  end

  def second_opinion!(recommendation, provider)
    raise Error, 'The recommendation does not belong to this user.' unless recommendation.user_id == user.id
    raise Error, 'Choose a different provider for a second opinion.' if provider == recommendation.provider
    raise Error, 'A second opinion from this provider already exists.' if
      recommendation.second_opinions.exists?(provider:)

    client = recommendation_client(provider)
    paper = recommendation.paper
    ranked = client.rank(
      favorites: user.bpapers.order(submitted: :desc).limit(12).to_a,
      followed: user.fauthors.limit(12).to_a,
      candidates: [paper],
      require_one: true,
    )
    entry = ranked.one? ? ranked.first : nil
    raise Error, 'The second opinion did not assess this paper. Please try again.' unless
      valid_entry?(entry, { paper.arxiv => paper })

    recommendation.with_lock do
      raise Error, 'A second opinion from this provider already exists.' if
        recommendation.second_opinions.exists?(provider:)

      recommendation.second_opinions.create!(
        provider:, model: LlmRecommendationClient.model_for(provider),
        score: entry['score'], reason: entry['reason'].to_s.truncate(500)
      )
    end
  rescue LlmRecommendationClient::Error => e
    raise Error, e.message
  end

  protected

  attr_reader :user

  def recommendation_client(provider)
    LlmRecommendationClient.new(user, provider)
  rescue LlmRecommendationClient::Error => e
    raise Error, e.message
  end

  def claim_lease!
    token = Time.current.round(6)
    user.with_lock do
      raise Error, 'Recommendations are already being refreshed.' if
        user.recommendation_processing_started_at&.after?(2.minutes.ago)

      user.update_columns(recommendation_processing_started_at: token)
    end
    token
  end

  def pending_papers
    papers = Paper.where(category_id: user.categories.select(:id), submitted: ..Date.current)
    papers = papers.where.not(id: user.bookmarks.select(:paper_id))
    papers = papers.where.not(id: user.hidden_papers.select(:paper_id))
    papers.where.not(id: user.recommendation_considerations.select(:paper_id))
  end

  def process_batch(client)
    candidates = pending_papers.includes(:authors, :category)
    candidates = candidates.order(submitted: :desc, id: :desc).limit(BATCH_SIZE).to_a
    return { processed: 0, remaining: 0 } if candidates.empty?

    favorites = user.bpapers.order(submitted: :desc).limit(12).to_a
    followed = user.fauthors.limit(12).to_a
    ranked = client.rank(favorites:, followed:, candidates:)

    by_arxiv = candidates.index_by(&:arxiv)
    selected = ranked.select do
      valid_entry?(it, by_arxiv)
    end
    selected = selected.uniq { it['arxiv_id'] }.first(10)
    raise Error, 'The recommendation service returned no eligible papers. Please try again.' if
      ranked.any? && selected.empty?

    user.recommendations.transaction do
      selected.each do
        recommendation = user.recommendations.find_or_initialize_by(paper: by_arxiv[it['arxiv_id']])
        recommendation.update!(
          score: it['score'], reason: it['reason'].to_s.truncate(500),
          provider: user.llm_provider, model: LlmRecommendationClient.model_for(user.llm_provider)
        )
      end
      now = Time.current
      rows = candidates.map do
        { user_id: user.id, paper_id: it.id, created_at: now, updated_at: now }
      end
      RecommendationConsideration.insert_all!(rows)
    end
    { processed: candidates.length, remaining: pending_papers.count }
  rescue LlmRecommendationClient::Error => e
    raise Error, e.message
  end

  def valid_entry?(entry, by_arxiv)
    entry.is_a?(Hash) && by_arxiv.key?(entry['arxiv_id']) &&
      entry['score'].is_a?(Numeric) && entry['score'].between?(0, 100) &&
      entry['reason'].is_a?(String) && entry['reason'].present?
  end
end
