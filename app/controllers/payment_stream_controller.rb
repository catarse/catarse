class PaymentStreamController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:moip]

  def thank_you
    unless session[:thank_you_id]
      flash[:failure] = I18n.t('payment_stream.thank_you.error')
      return redirect_to :root
    end

    if session[:_payment_token]
      backer = Backer.find_by_payment_token session[:_payment_token]
      session[:_payment_token] = nil
    end
    @project = Project.find session[:thank_you_id]
    @title = t('payment_stream.thank_you.title')
    session[:thank_you_id] = nil
  end
end
