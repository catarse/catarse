class PaypalController < ApplicationController

  before_filter :initialize_paypal

  def pay
    # raise "!!!!"
    backer = Backer.find params[:id]

    # this sets the data for whom to pay (the project owner)
    recipients = [{email: backer.project.user.email, amount: backer.value, primary: true}]

    response = @gateway.setup_purchase(
      return_url: success_paypal_url(backer),
      cancel_url: cancel_paypal_url(backer),
      # ipn_notification_url: url_for(:action => 'notify_action', :only_path => false),
      receiver_list: recipients,
      currency_code: :BRL,
      description: t('projects.pay.paypal_description'),
      :items => [{
          :name => backer.project.name,
          :description => t('projects.pay.paypal_description'),
          :amount => backer.value#,
          #:category => :Digital
        }]

    )
    backer.update_attribute :payment_method, 'PayPal'
    # for redirecting the customer to the actual paypal site to finish the payment.
    redirect_to @gateway.redirect_url_for(response["payKey"])

    # #rescue Paypal::Exception::APIError => e
    # #  raise "Message: #{e.message}<br/>Response: #{e.response.inspect}<br/>Details: #{e.response.details.inspect}"
    # rescue
    #   flash[:failure] = t('projects.pay.paypal_error')
    #   return redirect_to new_project_backer_path(backer.project)
    # end

  end

  def success
    raise params.inspect
    response = ActiveMerchant::Billing::AdaptivePaymentResponse.new(request.raw_post)
    backer = Backer.find notify.item_id
    if response.success?
      # backer.update_attribute :key, checkout.payment_info.first.transaction_id
      # backer.update_attribute :payment_token, params[:token]
      # backer.build_payment_detail.update_from_service
      # flash[:success] = t('projects.pay.success')
      backer.confirm!
      redirect_to thank_you_path
    else
      flash[:failure] = t('projects.pay.paypal_error')
      return redirect_to new_project_backer_path(backer.project)
    end

  end

  #   begin
  #     # details = @paypal.details(params[:token])
  #     # checkout = @paypal.checkout!(
  #     #   params[:token],
  #     #   details.payer.identifier,
  #     #   paypal_payment(backer)
  #     # )
  #     # if checkout.payment_info.first.payment_status == "Completed"
  #     #   
  #     #   
  #     #   
  #
  #     #   
  #     
  #   rescue
  #     flash[:failure] = t('projects.pay.paypal_error')
  #     return redirect_to new_project_backer_path(backer.project)
  #   end
  # end

    
    

    
  def cancel
    backer = Backer.find params[:id]
    flash[:failure] = t('projects.backers.checkout.paypal_cancel')
    redirect_to new_project_backer_path(backer.project)
  end

  protected

  def initialize_paypal
    @gateway ||=  ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      login: ::Configuration[:paypal_username],
      password: ::Configuration[:paypal_password],
      signature: ::Configuration[:paypal_signature],
      appid: ::Configuration[:paypal_appid]
    )
  end

  # def paypal_payment(backer)
  #   Paypal::Payment::Request.new(
  #     :currency_code => :BRL,
  #     :amount => backer.value,
  #     :description => t('projects.pay.paypal_description'),
  #     :items => [{
  #         :name => backer.project.name,
  #         :description => t('projects.pay.paypal_description'),
  #         :amount => backer.value#,
  #         #:category => :Digital
  #       }]
  #   )
  # end

end
