class PaymentDetail < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :backer

  def update_from_service
    if self.backer.payment_method == 'MoIP'
      response = request_to_moip
      process_moip_response(response) if response.present?
    elsif self.backer.payment_method == 'PayPal'
      @@gateway ||= PaymentGateway.new({
        :login => Configuration[:paypal_username],
        :password => Configuration[:paypal_password],
        :signature => Configuration[:paypal_signature]
      }) 
      response = @@gateway.details_for(self.backer.payment_token)
      process_paypal_response(response) if response.present?
    end
    self
  end

  def request_to_moip
    MoIP::Client.query(backer.payment_token)
  rescue
    []
  end

  def display_service_tax
    number_to_currency service_tax_amount, :unit => "R$", :precision => 2, :delimiter => '.'
  end

  def display_net_amount
    number_to_currency net_amount, :unit => "R$", :precision => 2, :delimiter => '.'
  end

  def display_total_amount
    number_to_currency total_amount, :unit => "R$", :precision => 2, :delimiter => '.'
  end

  def display_payment_date
    I18n.l(payment_date, :format => :simple) if payment_date.present?
  end

  private
  def process_paypal_response(response)
    # For moment only attribute persisted in database is the
    # service fee.
    begin
      self.service_tax_amount ||= response.params["tax_total"].to_f
      self.payer_email = response.params['payer']
      self.net_amount = response.params['order_total'].to_f
      self.total_amount = response.params['handling_total'].to_f
      self.service_tax_amount = response.params['tax_total'].to_f
      self.payment_date = response.params['timestamp'].to_date rescue nil
      self.payer_name = response.address['name']
      self.city = response.address['city']
      self.uf = response.address['state']
    rescue Exception => e
      Airbrake.notify({ :error_class => "Payment Detail Error [process paypal response]", :error_message => "Error: #{e.inspect}", :parameters => params}) rescue nil
    end
    self.save!
  end

  def process_moip_response(response)
    begin
      if response["Autorizacao"].present?
        authorized  = response["Autorizacao"]

        self.payer_name  = authorized["Pagador"]["Nome"]
        self.payer_email = authorized["Pagador"]["Email"]
        self.city        = authorized["EnderecoCobranca"]["Cidade"]
        self.uf          = authorized["EnderecoCobranca"]["Estado"]

        if authorized["Pagamento"].present?
          payment                      = authorized["Pagamento"]
          if payment.kind_of?(Array) && payment.first.present?
            self.payment_method          = payment.first["FormaPagamento"]
            self.net_amount              = payment.first["ValorLiquido"].to_f
            self.total_amount            = payment.first["TotalPago"].to_f
            self.service_tax_amount      = payment.first["TaxaMoIP"].to_f
            self.backer_amount_tax       = payment.first["TaxaParaPagador"].to_f
            self.payment_status          = payment.first["Status"]
            self.service_code            = payment.first["CodigoMoIP"]
            self.institution_of_payment  = payment.first["InstituicaoPagamento"]
            self.payment_date            = payment.first["Data"]
          else
            self.payment_method          = payment["FormaPagamento"]
            self.net_amount              = payment["ValorLiquido"].to_f
            self.total_amount            = payment["TotalPago"].to_f
            self.service_tax_amount      = payment["TaxaMoIP"].to_f
            self.backer_amount_tax       = payment["TaxaParaPagador"].to_f
            self.payment_status          = payment["Status"]
            self.service_code            = payment["CodigoMoIP"]
            self.institution_of_payment  = payment["InstituicaoPagamento"]
            self.payment_date            = payment["Data"]
          end
        end

        self.save!
      end
    rescue Exception => e
      Airbrake.notify({ :error_class => "Payment Detail Error [process moip response]", :error_message => "Error: #{e.inspect}", :parameters => params}) rescue nil
    end
  end


end
