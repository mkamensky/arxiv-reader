class UsersController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redir_back(messages: { alert: 'Try again later' }) }

  def create
    user = User.create(user_params)
    if user.persisted?
      start_new_session_for user
      flash.notice = "Welcome to ArxivReader, #{user.name.presence || user.email}!"
      redir_back
    else
      redir_back(errors: user.errors)
    end
  end

  protected

  def user_params
    params.expect(user: %i[email password name])
  end
end
