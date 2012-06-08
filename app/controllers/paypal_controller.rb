class PaypalController < ApplicationController
  SCOPE = "projects.backers.checkout"
  before_filter :initialize_paypal

  def pay
    backer = Backer.find params[:id]
    begin
        paypal_response = @paypal.setup(
          paypal_payment(backer),
          success_paypal_url(backer),
          cancel_paypal_url(backer),
          :no_shipping => true
        )
        backer.update_attribute :payment_method, 'PayPal'
        redirect_to paypal_response.redirect_uri
    rescue Exception => e
      Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{e.inspect}", :parameters => params}) rescue nil
      paypal_flash_error
      return redirect_to new_project_backer_path(backer.project)
    end
  end

  def success
    backer = Backer.find params[:id]
    begin
      details = @paypal.details params[:token]
      payment = paypal_payment(backer)
      checkout = @paypal.checkout!(params[:token], details.payer.identifier, payment)
      Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Checkout: #{checkout.inspect}", :parameters => params}) rescue nil
      if checkout.payment_info.first.payment_status == "Completed"
        backer.update_attributes({
          :key => checkout.payment_info.first.transaction_id,
          :payment_token => params[:token]
        })
        backer.build_payment_detail.update_from_service
        backer.confirm!
        paypal_flash_success
        redirect_to thank_you_path
      else
        Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{checkout.payment_info.first.inspect}", :parameters => params}) rescue nil
        paypal_flash_error
        return redirect_to new_project_backer_path(backer.project)
      end
    rescue Exception => e
      Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{e.message}", :parameters => params}) rescue nil
      paypal_flash_error
      return redirect_to new_project_backer_path(backer.project)
    end
  end

  def cancel
    @backer = Backer.find params[:id]
    flash[:failure] = t('paypal_cancel', scope: SCOPE)
    redirect_to new_project_backer_path(@backer.project)
  end

  protected

  def paypal_flash_error
    flash[:failure] = t('paypal_error', scope: SCOPE)
  end

  def paypal_flash_success
    flash[:success] = t('success', scope: SCOPE)
  end

  def initialize_paypal

    #NOTE: to use sandbox mode
    # Paypal.sandbox!

    @paypal = Paypal::Express::Request.new({
      :username => Configuration[:paypal_username],
      :password => Configuration[:paypal_password],
      :signature => Configuration[:paypal_signature]
    })
  end

  def paypal_payment(backer)
    Paypal::Payment::Request.new({
      currency_code: :BRL,
      amount: backer.value,
      description: t('paypal_description', scope: SCOPE),
      items: [{
          name: backer.project.name,
          description: t('paypal_description', scope: SCOPE),
          amount: backer.value
        }]
    })
  end

end
