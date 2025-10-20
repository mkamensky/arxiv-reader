class UsersController < ApplicationController
  before_action :require_authentication, only: %i[update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

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

  def user_params
    params.expect(
      user: [
        :email, :password, :name,
        { bpaper_ids: [], fauthor_ids: [], category_ids: [], hidden_ids: [] }
      ],
    )
  end

  alias_method :user, :object
end
