class ImportMissingPayablesAction
  def initialize(payment:)
    @payment = payment
  end

  def call
    payables = PagarMe::Payable.find_by(transaction_id: @payment.gateway_id)

    return if payables.size == 0

    ActiveRecord::Base.transaction do
      payables.each do |payable|
        @payment.gateway_payables.create!(
          gateway_id: payable.id,
          transaction_id: payable.transaction_id,
          fee: payable.fee.to_d / 100.00,
          data: payable.attributes
        )
      end

      cost = @payment.gateway_data['cost'].to_f / 100.00
      payables_fee = payables.to_a.sum(&:fee).to_f / 100.00

      gateway_fee = if @payment.is_credit_card?
        cost + payables_fee
      elsif @payment.slip_payment?
        payables_fee == 0 ? cost : payables_fee
      end

      @payment.update(gateway_fee: gateway_fee)
    end
  rescue => e
    Raven.extra_context(payment_id: @payment.id)
    Raven.capture_exception(e, level: 'fatal')
  end
end
