module Contribution::StateMachineHandler
  extend ActiveSupport::Concern

  included do
    state_machine :state, initial: :pending do
      state :pending, value: 'pending'
      state :waiting_confirmation, value: 'waiting_confirmation'
      state :confirmed, value: 'confirmed'
      state :canceled, value: 'canceled'
      state :refunded, value: 'refunded'
      state :requested_refund, value: 'requested_refund'
      state :chargeback, value: 'chargeback'
      state :refunded_and_canceled, value: 'refunded_and_canceled'
      state :deleted, value: 'deleted'
      state :invalid_payment, value: 'invalid_payment'

      event :push_to_trash do
        transition all => :deleted
      end

      event :pendent do
        transition all => :pending
      end

      event :waiting do
        transition pending: :waiting_confirmation
      end

      event :invalid do
        transition all => :invalid_payment
      end

      event :confirm do
        transition [:pending, :confirmed, :waiting_confirmation, :canceled, :deleted] => :confirmed
      end

      event :cancel do
        transition all => :canceled
      end

      event :request_refund do
        transition confirmed: :requested_refund, if: ->(contribution){
          contribution.user.credits >= contribution.value && !contribution.credits
        }
      end

      event :refund do
        transition [:requested_refund, :confirmed] => :refunded
      end

      event :hide do
        transition all => :refunded_and_canceled
      end

      after_transition do |contribution, transition|
        contribution.notify_observers :"from_#{transition.from}_to_#{transition.to}"

        to_column = "#{transition.to}_at".to_sym
        if contribution.has_attribute?(to_column)
          contribution.update_attribute to_column, DateTime.current
        end
      end

      after_transition any => [:refunded_and_canceled] do |contribution, transition|
        contribution.notify_to_contributor :refunded_and_canceled
      end
    end
  end
end
