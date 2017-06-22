# frozen_string_literal: true

module Payment::RequestRefundHandler
  extend ActiveSupport::Concern

  included do
    def already_in_refund_queue?
      refund_queue_set.any? do |job|
        job['class'] == 'DirectRefundWorker' && job['args'][0] == id
      end
    end

    def refund_queue_set
      @queue_set ||= Sidekiq::Queue.new
    end
  end
end
