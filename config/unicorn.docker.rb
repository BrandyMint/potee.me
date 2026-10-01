# Unicorn config for the container image: listen on TCP, log to stdout/stderr.
worker_processes (ENV['UNICORN_WORKERS'] || 2).to_i
listen (ENV['PORT'] || 3000).to_i, tcp_nopush: true
timeout 60
preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
