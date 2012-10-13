OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Settings.facebook.key, Settings.facebook.secret, scope: 'email'
  provider :twitter, Settings.twitter.key, Settings.twitter.secret
end
