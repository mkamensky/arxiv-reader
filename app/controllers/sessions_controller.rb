class SessionsController < ApplicationController
  before_action :require_authentication, except: %i[create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def create
    @user_info = request.env['omniauth.auth']

    if (user = User.authenticate_by(user_params))
      start_new_session_for user
      redirect_back_or_to after_authentication_url
    else
      redirect_back_or_to after_authentication_url, inertia: { errors: { base: 'Auth failed!' } }
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  protected

  def user_params
    params.expect(session: %i[email password])
  end
end
