# frozen_string_literal: true

class PaymentNotification < ActiveRecord::Base
  belongs_to :contribution
end
