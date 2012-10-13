OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Settings.facebook.key, Settings.facebook.secret, scope: 'email'
#   provider :twitter, 'aIge6ADDxeRLL0D0DfNiA', 'WZr5DPDmLNJK1JGEaStArnCki0Rau8yS3mZInpBSh0'
end
