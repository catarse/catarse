# frozen_string_literal: true

class BanishProjectAction

  def initialize(project_id:)
    @project = Project.find project_id
  rescue => e
    Raven.capture_exception(e, level: 'fatal')
  end

  def call
    if @project.is_sub?
      project_sub
    end

    # deletar projeto
    @project.push_to_trash

    # banir usuario
    @project.user.update_columns(banned_at: DateTime.now)
    BlacklistDocument.find_or_create_by number: @project.user.cpf
  rescue => e
    Raven.capture_exception(e, level: 'fatal')
  end

  def project_sub
    # Pedir o cancelamento de todas as assinaturas
    cw = CommonWrapper.new

    @project.subscriptions.each do |sub|
      cw.cancel_subscription(sub) if sub.status != "canceled" && sub.user.present?
    end

    refund_all_with_credit_card
    create_balance_transaction_for_boleto_payments
  end

  def refund_all_with_credit_card
    # Reembolsar usuarios com cartão crédito
    @project.subscription_payments.where("data ->> 'payment_method' = 'credit_card' ").find_each do |payment|
      if payment.status == 'paid'
        begin
          PagarMe.api_key = CatarseSettings[:pagarme_api_key]
          t = PagarMe::Transaction.find payment.gateway_general_data['gateway_id']
          t.refund if t.status == 'paid'
          balance_transaction_for_project_user(payment)
        rescue Exception => e
          Raven.capture_exception(e)
        end
      end
    end
  end

  def create_balance_transaction_for_boleto_payments
    # boleto bancario
    @project.subscription_payments.where("data ->> 'payment_method' = 'boleto' ").find_each do |payment|
      if payment.status == 'paid'
        begin
          balance_transaction_for_project_user(payment)
          # Remover saldo do apoiador de assinaturas
          BalanceTransaction.create!(
            user_id: payment.user.id,
            event_name: 'subscription_payment_refunded',
            amount: payment.amount,
            subscription_payment_uuid: payment.id,
            project_id: payment.project.id
          ) if !BalanceTransaction.where(event_name: 'subscription_payment_refunded', subscription_payment_uuid: payment.id, user_id: payment.user.id).present?
          payment.refund
        rescue Exception => e
          Raven.capture_exception(e)
        end
      end
    end
  end

  # Remover saldo do realizador de assinaturas
  def balance_transaction_for_project_user(payment)
    BalanceTransaction.create!(
      user_id: payment.project.user_id,
      event_name: 'subscription_payment_refunded',
      amount: ((payment.amount - (payment.amount * payment.project.service_fee)) * -1),
      subscription_payment_uuid: payment.id,
      project_id: payment.project.id
    ) if !BalanceTransaction.where(event_name: 'subscription_payment_refunded',
                                   subscription_payment_uuid: payment.id,
                                   user_id: payment.project.user_id
                                  ).present?
  end
end
