class PaypalController < ApplicationController

  SCOPE = "projects.backers.checkout"

  def pay
    @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      login: ::Configuration[:paypal_username],
      password: ::Configuration[:paypal_password],
      signature: ::Configuration[:paypal_signature],
      appid: ::Configuration[:paypal_appid]
    )

    @backer = Backer.find params[:id]

    # this sets the data for whom to pay (the project owner)
    recipients = [{email: @backer.project.user.email, amount: @backer.value, primary: true}]

    response = @gateway.setup_purchase(
      return_url: success_paypal_url(@backer),
      cancel_url: cancel_paypal_url(@backer),
      #NOTE: I dont' think we'll need IPN notifications
      # ipn_notification_url: url_for(:action => 'notify_action', :only_path => false),
      receiver_list: recipients,
      currency_code: :BRL,
      description: t('paypal_description', scope: SCOPE),
      items: [{
          name: @backer.project.name,
          
          amount: @backer.value
          #NOTE: Donno exactly what info should be sent, but that's
          # a minor detail.
          # description: t('paypal_description', scope: SCOPE),
          # category: :Digital
        }]
    )
    #NOTE: If paypal guys ask for info on requests, just
    # uncomment the line below:
    # raise @gateway.debug.inspect
    if response.success?
      @backer.update_attribute :payment_method, 'PayPal'
      # for redirecting the customer to the actual paypal site to finish the payment.
      redirect_to @gateway.redirect_url_for(response.pay_key)
      #NOTE: The original gem code is below... I'm still not sure
      # wether the line above will actually work.
      # redirect_to @gateway.redirect_url_for(response["payKey"])
    else
      flash[:failure] = t('paypal_error', scope: SCOPE)
      redirect_to new_project_backer_path(@backer.project)
    end

  end

  def success
    @paypal = Paypal::Express::Request.new(
      username: ::Configuration[:paypal_username],
      password: ::Configuration[:paypal_password],
      signature: ::Configuration[:paypal_signature]
    )

    @backer = Backer.find params[:id]
    begin
      details = @paypal.details(params[:token])
      checkout = @paypal.checkout!(
        params[:token],
        details.payer.identifier,
        paypal_payment(@backer)
      )
      info = checkout.payment_info.first
      if info.payment_status == "Completed"
        @backer.update_attribute :key, info.transaction_id
        @backer.update_attribute :payment_token, params[:token]
        @backer.build_payment_detail.update_from_service
        @backer.confirm!
        flash[:success] = t('success', scope: SCOPE)
        redirect_to thank_you_path
      else
        flash[:failure] = t('paypal_error', scope: SCOPE)
        return redirect_to new_project_backer_path(@backer.project)
      end
    rescue
      flash[:failure] = t('paypal_error', scope: SCOPE)
      return redirect_to new_project_backer_path(@backer.project)

    end
  end

  def cancel
    @backer = Backer.find params[:id]
    flash[:failure] = t('paypal_cancel', scope: SCOPE)
    redirect_to new_project_backer_path(@backer.project)
  end

  protected

  def paypal_payment(backer)
    Paypal::Payment::Request.new(
      currency_code: :BRL,
      amount: backer.value,
      description: t('paypal_description', scope: SCOPE),
      items: [{
          name: backer.project.name,
          description: t('paypal_description', scope: SCOPE),
          amount: backer.value
        }]
    )
  end

end