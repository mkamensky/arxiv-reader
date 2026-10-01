Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
  unless Rails.env.test?
    creds = Rails.application.credentials
    provider :github, creds.github.client_id, creds.github.client_secret,
             scope: 'read:user'
    provider :google_oauth2, creds.google.client_id, creds.google.client_secret,
             name: 'google'
    provider :orcid, creds.orcid.client_id, creds.orcid.client_secret
  end
end
OmniAuth.config.logger = Rails.logger
