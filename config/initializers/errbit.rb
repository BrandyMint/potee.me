if defined? Airbrake
   Airbrake.configure do |config|
      config.api_key		 	= '4b713ec91c071546d237b529deda63d2'
      config.host			= 'errbit.brandymint.ru'
      config.port			= 80
      config.secure			= config.port == 443
   end
end
