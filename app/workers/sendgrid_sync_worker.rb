class SendgridSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'actions'
end
