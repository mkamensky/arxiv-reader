class RecommendationFeedbacksController < ApplicationController
  before_action :require_authentication
  before_action :authorize_current_user

  def create
    paper = Paper.find(params.expect(:paper_id))
    sentiment = params.expect(:sentiment)
    return redirect_back_or_to recommendations_path, alert: 'Choose positive or negative feedback.' if RecommendationFeedback::VALUES.exclude?(sentiment)

    feedback = current_user.recommendation_feedbacks.find_or_initialize_by(paper:)
    feedback.update!(sentiment:)
    redirect_back_or_to recommendations_path
  end

  protected

  def auth_item
    nil
  end

  def authorize_current_user
    authorize current_user, :show?
  end
end
