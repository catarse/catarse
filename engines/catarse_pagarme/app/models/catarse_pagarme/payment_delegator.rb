# frozen_string_literal: true

module CatarsePagarme
  class PaymentDelegator
    attr_accessor :payment, :transaction

    def initialize(payment)
      configure_pagarme
      self.payment = payment
    end

    def change_status_by_transaction(transaction_status)
      case transaction_status
      when 'pending_review' then
        self.payment.try(:notify_about_pending_review)
      when 'paid' then
        self.payment.pay unless self.payment.paid?
      when 'pending_refund' then
        self.payment.request_refund unless self.payment.pending_refund?
      when 'refunded' then
        if self.payment.pending?
          self.payment.refuse
        else
          self.payment.refund unless self.payment.refunded?
        end
      when 'refused' then
        self.payment.refuse unless self.payment.refused?
      when 'chargedback' then
        self.payment.chargeback unless self.payment.chargeback?
      end
    end

    def update_transaction
      fill_acquirer_data
      payment.installment_value = (value_for_installment / 100.0).to_f
      PaymentEngines.import_payables(payment)
      payment.save!
    end

    def fill_acquirer_data
      data = transaction.try(:to_hash) || payment.gateway_data || {}
      payment.gateway_data = data.merge({
        acquirer_name: transaction.acquirer_name,
        acquirer_tid: transaction.tid,
        card_brand: transaction.try(:card_brand)
      })
      payment.save
    end

    def refund
      if payment.is_credit_card?
        transaction.refund
      else
        transaction.refund(bank_account_attributes)
      end
    end

    def value_for_transaction
      (self.payment.value * 100).to_i
    end

    def value_with_installment_tax(installment)
      current_installment = get_installment(installment)

      if current_installment.present?
        current_installment['amount']
      else
        value_for_transaction
      end
    end

    def value_for_installment(installment = transaction.installments || 0)
      get_installment(installment).try(:[], "installment_amount")
    end

    def transaction
      gateway_id = self.payment.gateway_id
      return nil unless gateway_id.present?

      @transaction ||= ::PagarMe::Transaction.find_by_id(gateway_id)
      _transaction = @transaction.kind_of?(Array) ? @transaction.last : @transaction

      raise "transaction gateway not match #{_transaction.id} != #{gateway_id}" unless _transaction.id.to_s == gateway_id.to_s

      _transaction
    end

    def get_installment(installment_number)
      installment = get_installments['installments'].select do |_installment|
        !_installment[installment_number.to_s].nil?
      end

      installment[installment_number.to_s]
    end

    def current_interest_rate
      project.interest_rate.presence || CatarsePagarme.configuration.interest_rate
    end

    def current_free_installments
      project.free_installments
    end

    def project
      self.payment.try(:project)
    end

    def get_installments
      @installments ||= PagarMe::Transaction.calculate_installments({
        amount: self.value_for_transaction,
        free_installments: current_free_installments,
        interest_rate: current_interest_rate
      })
    end

    # Transfer payment amount to payer bank account via transfers API
    def transfer_funds
      raise "payment must be paid" if !payment.paid?

      bank_account = PagarMe::BankAccount.new(bank_account_attributes.delete(:bank_account))
      bank_account.create
      raise "unable to create an bank account" unless bank_account.id.present?

      transfer = PagarMe::Transfer.new({
        bank_account_id: bank_account.id,
        amount: value_for_transaction
      })
      transfer.create
      raise "unable to create a transfer" unless transfer.id.present?

      #avoid sending notification
      payment.update(state: 'pending_refund')
      payment.payment_transfers.create!({
        user: payment.user,
        transfer_id: transfer.id,
        transfer_data: transfer.to_json
      })
    end

    protected

    def bank_account_attributes
      user = payment.user
      bank = user.bank_account
      pagarme_account_type = if bank.account_type.include?('conta_facil')
        'conta_corrente'
      else
        bank.account_type
      end
      bank_account_attrs = {
        bank_account: {
          bank_code: (bank.bank_code || bank.name),
          agencia: bank.agency,
          agencia_dv: bank.agency_digit,
          conta: bank.account,
          conta_dv: bank.account_digit,
          legal_name: user.name[0..29],
          document_number: user.cpf,
          type: pagarme_account_type
        }
      }

      bank_account_attrs[:bank_account].delete(:agencia_dv) if bank.agency_digit.blank?
      return bank_account_attrs
    end

    def configure_pagarme
      ::PagarMe.api_key = CatarsePagarme.configuration.api_key
    end
  end
end
