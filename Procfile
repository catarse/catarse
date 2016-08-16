web: bundle exec unicorn_rails -p $PORT -c config/unicorn.rb
worker: bundle exec sidekiq -c 20 -C config/sidekiq.yml
worker_notifications: bundle exec rake listen:sync_notifications
