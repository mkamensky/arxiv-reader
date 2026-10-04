class RecommendationsController < ApplicationController
  before_action :require_authentication
  before_action :authorize_current_user

  def show
    generated_count = visible_recommendations.count
    total = generated_count + visible_manual_papers.count
    current_page = (params[:page].to_i.positive? ? params[:page].to_i : 1).clamp(1, [(total / 20.0).ceil, 1].max)
    render inertia: {
      recommendations: -> {
        offset = (current_page - 1) * 20
        saved_scope = visible_recommendations.includes(:second_opinions, paper: :authors)
        saved = saved_scope.order(score: :desc, id: :desc).offset(offset).limit(20).to_a
        generated = saved.map do
          recommendation = it
          recommendation_data(recommendation).merge(
            paper: recommendation.paper.inertia_json(
              include: { authors: Author.inertia_params },
            ),
          )
        end
        manual_offset = [offset - generated_count, 0].max
        manual_limit = 20 - generated.length
        manual = if manual_limit.positive?
          manual_scope = visible_manual_papers.includes(:authors)
          manual_scope = manual_scope.order(submitted: :desc, id: :desc).offset(manual_offset).limit(manual_limit)
          manual_scope.map { manual_entry(it) }
        else
          []
        end
        generated + manual
      },
      page: current_page,
      total:,
      pendingCount: -> { PaperRecommender.new(current_user).pending_count },
      hasFollowedCategories: current_user.categories.exists?,
      availableProviders: LlmConnection::PROVIDERS.select do
        LlmRecommendationClient.available_for?(current_user, it)
      end,
    }
  end

  def create
    result = PaperRecommender.new(current_user).refresh!
    notice =
      if result[:processed].zero?
        'All papers in your followed categories have been considered.'
      else
        "Considered #{result[:processed]} papers; #{result[:remaining]} remain."
      end
    redirect_to recommendations_path, notice:
  rescue PaperRecommender::Error => e
    redirect_to recommendations_path, alert: e.message
  end

  def sidebar
    page = [params[:page].to_i, 1].max
    paper_ids = visible_recommendations.select(:paper_id)
    manual_ids = visible_manual_papers.select(:id)
    papers = Paper.where(id: paper_ids).or(Paper.where(id: manual_ids)).
             includes(:authors).order(submitted: :desc, id: :desc).
             offset((page - 1) * 20).limit(21).to_a
    render json: {
      papers: papers.first(20).map do |paper|
        { id: paper.id, value: paper.value, label: paper.label,
          authors: paper.authors.map(&:label) }
      end,
      nextPage: papers.length > 20 ? page + 1 : nil,
    }
  end

  def assessment
    recommendation = current_user.recommendations.includes(:second_opinions).
                     find_by!(paper_id: params[:paper_id])
    render json: {
      recommendation: recommendation_data(recommendation),
      availableProviders: LlmConnection::PROVIDERS.select do |provider|
        LlmRecommendationClient.available_for?(current_user, provider)
      end,
    }
  end

  protected

  def recommendation_data(recommendation)
    {
      id: recommendation.id, score: recommendation.score,
      reason: recommendation.reason, provider: recommendation.provider,
      model: recommendation.model,
      secondOpinions: recommendation.second_opinions.map do |opinion|
        { provider: opinion.provider, model: opinion.model,
          score: opinion.score, reason: opinion.reason }
      end,
    }
  end

  def visible_recommendations
    relation = current_user.recommendations.joins(:paper)
    relation = relation.where(papers: { category_id: current_user.categories.select(:id) })
    relation = relation.where.not(paper_id: current_user.bookmarks.select(:paper_id))
    relation = relation.where.not(paper_id: current_user.hidden_papers.select(:paper_id))
    relation.where.not(
      paper_id: current_user.recommendation_feedbacks.
                where(sentiment: 'negative').select(:paper_id),
    )
  end

  def visible_manual_papers
    relation = Paper.where(
      id: current_user.recommendation_feedbacks.
          where(sentiment: 'positive').select(:paper_id),
    )
    relation = relation.where(category_id: current_user.categories.select(:id))
    relation = relation.where.not(id: current_user.recommendations.select(:paper_id))
    relation = relation.where.not(id: current_user.bookmarks.select(:paper_id))
    relation.where.not(id: current_user.hidden_papers.select(:paper_id))
  end

  def manual_entry(paper)
    {
      id: "manual-#{paper.id}",
      score: nil,
      reason: nil,
      provider: nil,
      model: nil,
      secondOpinions: [],
      paper: paper.inertia_json(include: { authors: Author.inertia_params }),
    }
  end

  def auth_item
    nil
  end

  def authorize_current_user
    authorize current_user, :show?
  end

  def page_title
    'Recommended papers'
  end
end
