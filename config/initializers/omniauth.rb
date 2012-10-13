OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '435822783141513', 'e021c8dd40c3966475002285eb9d31a1', scope: 'email'
end
