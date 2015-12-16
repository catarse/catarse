class DonationsController < ApplicationController

  helper_method :resource

  def confirm;end

  def create
    raise Pundit::NotAuthorizedError if !current_user
    return redirect_to explore_path if current_user.pending_refund_payments.empty?
    @donation = Donation.create(user: current_user)
    @donation.notify(:contribution_donated, current_user)
    update_pending_refunds
  end

  def resource
    @donation
  end

  private
  def update_pending_refunds
    resource.update_attribute :amount, current_user.pending_refund_payments.sum(&:value)
    current_user.pending_refund_payments.each do |payment|
      payment.contribution.update_attribute :donation, @donation
      payment.update_attribute :state, 'refunded'
    end
  end

end
