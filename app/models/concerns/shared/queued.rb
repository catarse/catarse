module Shared::Queued
  extend ActiveSupport::Concern

  included do

    def remove_scheduled_job(worker_class_name, first_arg_c = self.id)
      on_scheduled_jobs(worker_class_name, first_arg_c) do |job|
        job.delete
      end
    end

    def exists_on_scheduled_jobs(class_name, args)
      scheduled_queue.any? {|j| job_match?(j, class_name, args) }
    end

    private

    def on_scheduled_jobs(class_name, first_arg_c)
      scheduled_queue.each do |job|
        yield job if job_match?(job, class_name, first_arg_c)
      end
    end

    def job_match?(job, class_name, args)
      job['class'] == class_name && (args.kind_of?(Array) ? job_args == args : job_args[0] == args)
    end

    def scheduled_queue
      Sidekiq::ScheduledSet.new
    end

  end
end
