class DonationsController < ApplicationController

  helper_method :resource

  def create
    raise Pundit::NotAuthorizedError if !current_user
    return if current_user.pending_refund_payments.empty? && current_user.credits == 0
    @donation = Donation.create(user: current_user)
    @donation.notify(:contribution_donated, current_user)
    update_pending_refunds
  end

  def resource
    @donation
  end

  private
  def update_pending_refunds
    if !current_user.pending_refund_payments.empty?
      resource.update_attribute :amount, current_user.pending_refund_payments.sum(&:value)
      current_user.pending_refund_payments.each do |payment|
        payment.contribution.update_attribute :donation, @donation
        payment.update_attribute :state, 'refunded'
      end
    end

    if current_user.credits > 0
      if resource.amount.nil?
        resource.update_attribute :amount, current_user.credits
      else
        Donation.create(user: current_user, amount: current_user.credits)
      end
    end
  end


end
