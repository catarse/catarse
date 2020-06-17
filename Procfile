web: bundle exec unicorn_rails -p $PORT -c config/unicorn.rb
worker: bundle exec sidekiq -c 10 -C config/sidekiq.yml
metric_storage_worker: bundle exec sidekiq -c 5 -q metric_storage
export_report: bundle exec sidekiq -c 5 -q export_report
worker_notifications: bundle exec rake listen:sync_notifications
worker_rdstation: bundle exec rake listen:sync_rdstation
worker_refresh_balance_transaction_metadata: bundle exec rake listen:sync_balance_transaction_metadata
cache_reward: bundle exec rake cache:reward_metric_storages
