class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

  def omni
    debugger unless userinfo

    user = User.find_or_initialize_by(email: userinfo[:email]) do
      it.name = userinfo[:name]
      it.password = it.password_confirmation = SecureRandom.base64(24)
    end
    user.avatar ||= userinfo[:image]
    user.github ||= userinfo[:nickname]
    user.save!
    login(user)
    redir_back
  rescue ActiveRecord::RecordInvalid => e
    debugger
  end

  def create
    if (user = User.authenticate_by(user_params))
      login(user)
      redir_back
    else
      redir_back errors: { base: 'Auth failed!' }
    end
  end

  def destroy
    terminate_session
    redirect_to subject_path
    #redir_back
  end

  protected

  def object
    cur_session
  end

  def user_params
    params.expect(session: %i[email password])
  end

  def login(user)
    terminate_session
    start_new_session_for user
    pundit_reset!
    skip_authorization
  end

  def userinfo
    @userinfo ||= (request.env['omniauth.auth'] || {})[:info]
  end
end
