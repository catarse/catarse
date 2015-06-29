module Payment::RequestRefundHandler
  extend ActiveSupport::Concern

  included do
    def already_in_refund_queue?
      refund_queue_set.any? do |job|
        job['class'] == 'DirectRefundWorker' && job['args'][0] == self.id
      end
    end

    def refund_queue_set
      @queue_set ||= Sidekiq::Queue.new
    end
  end
end

