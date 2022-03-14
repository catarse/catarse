# frozen_string_literal: true

class SubscriptionPaymentPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    super
    @record = record
  end

  def receipt?
    record.user == user || user.try(:admin?)
  end
end
