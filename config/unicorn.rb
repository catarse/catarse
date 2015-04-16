# Due to catarse's heavy page load, we are setting it to 4 workers
# 1024/4 = 240MB for each web worker
# 512/4  = 128MB for each web worker (in this case, make it 3 worker processes)
if ENV['PX_DYNO']
  worker_processes 18
else
  worker_processes 3
end

# Requests with more than 30 sec will be killed
timeout 30


# Preload entire app for fast forking.
preload_app true

# Ensure the agent is started using Unicorn.
# This is needed when using Unicorn and preload_app is not set to true.
# See https://docs.newrelic.com/docs/ruby/no-data-with-unicorn
if defined?(Unicorn) && File.basename($0).start_with?('unicorn')
  ::NewRelic::Agent.manual_start()
  ::NewRelic::Agent.after_fork(:force_reconnect => true)
end

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end


# Please, run it like this `bundle exec unicorn_rails -c config/unicorn.rb -p 3000`
# And change port or other params as you'd like.

