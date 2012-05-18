class PaypalController < ApplicationController

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
    #rescue Paypal::Exception::APIError => e
    #  raise "Message: #{e.message}<br/>Response: #{e.response.inspect}<br/>Details: #{e.response.details.inspect}"
    rescue Exception => e
      Exceptional.handle(e) rescue nil
      flash[:failure] = t('projects.pay.paypal_error')
      return redirect_to new_project_backer_path(backer.project)
    end
  end

  def success
    backer = Backer.find params[:id]
    begin
      details = @paypal.details(params[:token])
      checkout = @paypal.checkout!(
        params[:token],
        details.payer.identifier,
        paypal_payment(backer)
      )
      if checkout.payment_info.first.payment_status == "Completed"
        backer.update_attribute :key, checkout.payment_info.first.transaction_id
        backer.update_attribute :payment_token, params[:token]
        backer.build_payment_detail.update_from_service
        backer.confirm!
        flash[:success] = t('projects.pay.success')
        redirect_to thank_you_path
      else
        flash[:failure] = t('projects.pay.paypal_error')
        return redirect_to new_project_backer_path(backer.project)
      end
    rescue
      flash[:failure] = t('projects.pay.paypal_error')
      return redirect_to new_project_backer_path(backer.project)
    end
  end

  def cancel
    backer = Backer.find params[:id]
    flash[:failure] = t('projects.pay.paypal_cancel')
    redirect_to new_project_backer_path(backer.project)
  end

  protected

  def initialize_paypal

    # TODO remove the sandbox! when ready
    #Paypal.sandbox!
    # TODO remove the sandbox! when ready

    @paypal = Paypal::Express::Request.new(
      :username   => ::Configuration[:paypal_username],
      :password   => ::Configuration[:paypal_password],
      :signature  => ::Configuration[:paypal_signature]
    )
  end

  def paypal_payment(backer)
    Paypal::Payment::Request.new(
      :currency_code => :BRL,
      :amount => backer.value,
      :description => t('projects.pay.paypal_description'),
      :items => [{
          :name => backer.project.name,
          :description => t('projects.pay.paypal_description'),
          :amount => backer.value#,
          #:category => :Digital
        }]
    )
  end

end
