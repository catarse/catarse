class DonationsController < ApplicationController
  inherit_resources
  actions :create

  def create
    @donation = Donation.create
    resource.notify(:contribution_donated, current_user)
    current_user.pending_refund_payments.each do |payment|
      contribution = payment.contribution
      contribution.donation = @donation
      contribution.save!

      payment.state = 'refunded'
      payment.save!

    end
  end

end
