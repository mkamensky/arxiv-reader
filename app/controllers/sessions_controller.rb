class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

  def create
    @user_info = request.env['omniauth.auth']

    if (user = User.authenticate_by(user_params))
      start_new_session_for user
      redir_back
    else
      redir_back errors: { base: 'Auth failed!' }
    end
  end

  def destroy
    terminate_session
    redir_back
  end

  protected

  def user_params
    params.expect(session: %i[email password])
  end
end
