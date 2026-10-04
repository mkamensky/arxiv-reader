class SecondOpinionsController < ApplicationController
  before_action :require_authentication
  before_action :authorize_current_user
  rate_limit to: 10, within: 1.hour, by: -> { current_user.id }, only: :create, with: -> {
    redirect_to recommendations_path, alert: 'Please wait before requesting more second opinions.'
  }

  def create
    recommendation = current_user.recommendations.find(params.expect(:recommendation_id))
    PaperRecommender.new(current_user).second_opinion!(recommendation, params.expect(:provider))
    redirect_back_or_to recommendations_path, notice: 'Second opinion saved.'
  rescue PaperRecommender::Error => e
    redirect_back_or_to recommendations_path, alert: e.message
  end

  protected

  def auth_item
    nil
  end

  def page_title
    'Second opinion'
  end

  def authorize_current_user
    authorize current_user, :show?
  end
end
