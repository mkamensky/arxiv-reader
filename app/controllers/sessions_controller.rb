class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    flash.alert = 'Try again later'
    redir_back
  }

  def omni
    user = User.find_or_initialize_by(email: userinfo[:email]) do
      it.password = it.password_confirmation = SecureRandom.base64(24)
    end
    Rails.logger.debug { "Info from #{provider}: #{userinfo}" }
    user.name ||= userinfo[:name]
    user.avatar ||= userinfo[:image]
    user.github ||= userinfo[:nickname] if provider == 'github'
    user.orcid ||= authinfo[:uid] if provider == 'orcid'
    user.save!
    login(user)
    redir_back
    #  rescue ActiveRecord::RecordInvalid => e
    #    debugger
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

  def authinfo
    @authinfo ||= request.env['omniauth.auth'] || {}
  end

  def userinfo
    authinfo[:info]
  end

  def provider
    authinfo[:provider]
  end
end
