class DispatchProjectMetricStorageRefreshTask
  include Rake::DSL

  def initialize
    namespace :projects do
      task dispatch_metric_storage_refresh: :environment do
        call
      end

      # NOTE: this cmd is only for sandbox environment
      task dispatch_metric_storage_refresh_loop: :environment do
        raise 'run only in sandox' unless Rails.env.sandbox?
        loop do
          call
          sleep 300
        end
      end
    end
  end

  private

  def call
    ProjectMetricStorage
      .joins(:project)
      .where("refreshed_at < now() - '5 minutes'::interval")
      .where(projects: {state: 'online'})
      .pluck(:project_id)
      .each do |id|
      ProjectMetricStorageRefreshWorker.perform_async(id)
    end
  end
end

DispatchProjectMetricStorageRefreshTask.new
