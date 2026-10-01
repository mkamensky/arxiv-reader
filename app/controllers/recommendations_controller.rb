class RecommendationsController < ApplicationController
  before_action :require_authentication
  before_action :authorize_current_user

  def show
    total = visible_recommendations.count
    current_page = (params[:page].to_i.positive? ? params[:page].to_i : 1).clamp(1, [(total / 20.0).ceil, 1].max)
    render inertia: {
      recommendations: -> {
        saved = visible_recommendations.includes(:second_opinions, paper: :authors)
        saved = saved.order(score: :desc, id: :desc).offset((current_page - 1) * 20).limit(20)
        saved.map do
          recommendation = it
          {
            id: recommendation.id,
            score: recommendation.score,
            reason: recommendation.reason,
            provider: recommendation.provider,
            model: recommendation.model,
            secondOpinions: recommendation.second_opinions.map do
              {
                provider: it.provider,
                model: it.model,
                score: it.score,
                reason: it.reason,
              }
            end,
            paper: recommendation.paper.inertia_json(
              include: { authors: Author.inertia_params },
            ),
          }
        end
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

  protected

  def visible_recommendations
    relation = current_user.recommendations.joins(:paper)
    relation = relation.where(papers: { category_id: current_user.categories.select(:id) })
    relation = relation.where.not(paper_id: current_user.bookmarks.select(:paper_id))
    relation.where.not(paper_id: current_user.hidden_papers.select(:paper_id))
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
