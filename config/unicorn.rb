# Run: cd /project/; bundle exec unicorn_rails -c config/unicorn.rb -E production -D

load File.expand_path('setup_load_paths.rb', File.dirname(__FILE__))

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

rails_env = ENV['RACK_ENV'] || 'production'
puts "Unicorn env: #{rails_env}"

if rails_env=='production'
  worker_processes 10
  #TODO: избавиться от прописывания пользователя в нескольких местах
  APP_PATH = ENV['APP_PATH'] || '/home/wwwpotee/potee.me/'
  working_directory APP_PATH + "current"

  listen APP_PATH + "shared/pids/unicorn.sock"
  pid APP_PATH + "shared/pids/unicorn.pid"
  stderr_path APP_PATH + "shared/log/unicorn.stderr.log"
  stdout_path APP_PATH + "shared/log/unicorn.stdout.log"
elsif rails_env=='development'
  worker_processes 3
  APP_PATH = ENV['APP_PATH'] || '/home/wwwpotee/stage.potee.ru/'
  working_directory APP_PATH + "current"

  listen APP_PATH + "shared/pids/unicorn.sock"
  pid APP_PATH + "shared/pids/unicorn.pid"
  stderr_path APP_PATH + "shared/log/unicorn.stderr.log"
  stdout_path APP_PATH + "shared/log/unicorn.stdout.log"
else
  APP_PATH = ENV['APP_PATH'] || '/home/wwwpotee/stage.potee.ru/'
  stderr_path "log/unicorn.stderr.log"
  stdout_path "log/unicorn.stdout.log"
  pid "tmp/unicorn.pid"

  listen 4000, :tcp_nopush => true
end

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 60

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

# Собираем статистику по сбору мусора на new_relic
GC::Profiler.enable

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = Rails.root + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  # old_pid = "#{server.config[:pid]}.oldbin"
  # if old_pid != server.pid
  #   begin
  #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
  #     Process.kill(sig, File.read(old_pid).to_i)
  #   rescue Errno::ENOENT, Errno::ESRCH
  #   end
  # end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end



# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# Spec's
#   http://sirupsen.com/setting-up-unicorn-with-nginx/
#   http://sleekd.com/general/configuring-nginx-and-unicorn/
#   https://gist.github.com/206253
#   https://gist.github.com/410309

# nginx example:
#   https://github.com/defunkt/unicorn/blob/master/examples/nginx.conf
#   http://unicorn.bogomips.org/examples/nginx.conf


# Examples:
#
# http://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn
#
# upgrade + monit + rc.d:
# http://shapeshed.com/journal/managing-unicorn-workers-with-monit/ 
# https://gist.github.com/1221753
