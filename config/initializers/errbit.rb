# Errors are reported only when an Errbit/Airbrake key is provided.
if defined?(Airbrake) && ENV['AIRBRAKE_API_KEY'].present?
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_HOST'] || 'errbit.brandymint.ru'
    config.port    = (ENV['AIRBRAKE_PORT'] || 443).to_i
    config.secure  = config.port == 443
  end
end
