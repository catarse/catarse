#require "#{Rails.root}/app/business/payment_gateway"

class PaypalController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:notifications]

  SCOPE = "projects.backers.checkout"
  before_filter :initialize_paypal

  def notifications
    backer = Backer.find params[:id]
    response = @@express_gateway.details_for(backer.payment_token)
    if response.params['transaction_id'] == params['txn_id']
      if response.success?
        backer.confirm!
      else
        backer.confirmed = false
        backer.save
      end
      render nothing: true
    else
      render text: 'Transaction ID - not found!', status: 404
    end
  end

  def pay
    backer = current_user.backs.find params[:id]
    begin
      response = @@express_gateway.setup_purchase(backer.price_in_cents, {
        ip: request.remote_ip,
        return_url: success_paypal_url(backer),
        cancel_return_url: cancel_paypal_url(backer),
        currency_code: 'BRL',
        description: t('paypal_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
        notify_url: notifications_paypal_url(backer)
      })

      backer.update_attribute :payment_method, 'PayPal'
      backer.update_attribute :payment_token, response.token
      if response.params['correlation_id']
        backer.update_attribute :payment_id, response.params['correlation_id']
      end
      redirect_to @@express_gateway.redirect_url_for(response.token)
    rescue Exception => e
      Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{e.inspect}", :parameters => params}) rescue nil
      Rails.logger.info "-----> #{e.inspect}"
      paypal_flash_error
      return redirect_to new_project_backer_path(backer.project)
    end    
  end

  def success
    backer = current_user.backs.find params[:id]
    begin
      details = @@express_gateway.details_for(backer.payment_token)
      response = @@express_gateway.purchase(backer.price_in_cents, {
        ip: request.remote_ip,
        token: backer.payment_token,
        payer_id: details.payer_id
      })

      if response.success?
        backer.confirm!
      end

      if details.params['transaction_id'] 
        backer.update_attribute :payment_id, details.params['transaction_id']
      end

      session[:thank_you_id] = backer.project.id
      session[:_payment_token] = backer.payment_token

      paypal_flash_success
      redirect_to thank_you_path
    rescue Exception => e
      Airbrake.notify({ :error_class => "Paypal Error", :error_message => "Paypal Error: #{e.message}", :parameters => params}) rescue nil
      Rails.logger.info "-----> #{e.inspect}"
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
    if ::Configuration[:paypal_username] and ::Configuration[:paypal_password] and ::Configuration[:paypal_signature]
      @@express_gateway ||= PaymentGateway.new({
        :login => ::Configuration[:paypal_username],
        :password => ::Configuration[:paypal_password],
        :signature => ::Configuration[:paypal_signature]
      })
    else
      puts "[PayPal] An API Certificate or API Signature is required to make requests to PayPal"
    end
  end

  def paypal_payment(backer)
    {
      currency_code: 'BRL',
      description: t('paypal_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
      items: [{
        name: backer.project.name,
        description: t('paypal_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
        amount: backer.value
      }]
    }
  end

end
