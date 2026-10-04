class UsersController < ApplicationController
  before_action :require_authentication, only: %i[update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

  def show
    render inertia: {
      llmAvailable: {
        openai: Rails.configuration.x.llm_recommendations.openai_api_key.present?,
        gemini: Rails.configuration.x.llm_recommendations.gemini_api_key.present?,
      },
      llmSettings: current_user&.llm_settings || {},
      llmModelOptions: -> { llm_model_options },
    }
  end

  def create
    user = User.create(user_params)
    if user.persisted?
      start_new_session_for user
      pundit_reset!
      skip_authorization
      flash.notice = "Welcome to ArxivReader, #{user.name.presence || user.email}!"
      redir_back
    else
      redir_back(errors: user.errors)
    end
  end

  def update
    if user&.update(user_params)
      redir_back
    else
      redir_back(errors: user.errors)
    end
  end

  protected

  def llm_model_options
    LlmConnection::PROVIDERS.index_with { LlmConnection.model_options_for(it) }
  rescue RubyLLM::ModelRegistryError => e
    Rails.logger.warn("Could not load recommendation model options: #{e.class.name}")
    {}
  end

  def user_params
    params.expect(
      user: [
        :email, :password, :name, :llm_mode, :llm_provider, :llm_api_key, :clear_llm_api_key,
        :llm_model, :llm_thinking_level,
        {
          bpaper_ids: [],
          fauthor_ids: [],
          category_ids: [],
          hidden_ids: [],
          tags_attributes: [[:id, { paper_ids: [] }]],
        }
      ],
    )
  end

  alias_method :user, :object
end
