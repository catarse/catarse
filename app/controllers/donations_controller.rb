class DonationsController < ApplicationController

  helper_method :resource

  def create
    @donation = Donation.create
    @donation.notify(:contribution_donated, current_user)
    update_pending_refunds
  end

  def resource
    @donation
  end

  private
  def update_pending_refunds
    current_user.pending_refund_payments.each do |payment|
      payment.contribution.update_attribute :donation, @donation

      payment.state = 'refunded'
      payment.save!
    end
  end


end
