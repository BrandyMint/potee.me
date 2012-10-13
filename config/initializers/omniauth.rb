OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Settings.facebook.key, Settings.facebook.secret, scope: 'email'
  provider :twitter, Settings.twitter.key, Settings.twitter.secret
  provider :google_oauth2, Settings.google.key, Settings.google.secret,
           access_type: :online, approval_prompt: ''
end
