class PaymentStreamController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:moip]

  # this action receive a post request from moip service.
  def moip
    moip_request = PaymentHistory::Moip.new(params).process_request!
    return render :nothing => true, :status => moip_request.response_code
  end
end