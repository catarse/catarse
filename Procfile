web: bundle exec unicorn_rails -p $PORT -c config/unicorn.rb
worker: bundle exec sidekiq -c 10 -C config/sidekiq.yml
metric_storage_worker: bundle exec sidekiq -c 20 -q metric_storage
export_report: bundle exec sidekiq -c 5 -q export_report
worker_notifications: bundle exec rake listen:sync_notifications
worker_rdstation: bundle exec rake listen:sync_rdstation
worker_refresh_balance_transaction_metadata: bundle exec rake listen:sync_balance_transaction_metadata
cache_reward: bundle exec rake cache:reward_metric_storages
sub_cache_reward: bundle exec rake cache:refresh_subscription_reward_metrics
con_cache_reward: bundle exec rake cache:refresh_contribution_reward_metrics
pay_cache_reward: bundle exec rake cache:refresh_payment_reward_metrics
rewards_dispatch_metric_storage_refresh: bundle exec rake rewards:dispatch_metric_storage_refresh_loop
projects_dispatch_metric_storage_refresh: bundle exec rake projects:dispatch_metric_storage_refresh_loop

