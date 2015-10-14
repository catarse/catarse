class TransferWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def bank_account_attributes(user)
    bank = user.bank_account

    {
      bank_account: {
        bank_code: (bank.bank_code || bank.name),
        agencia: bank.agency,
        agencia_dv: bank.agency_digit,
        conta: bank.account,
        conta_dv: bank.account_digit,
        legal_name: bank.owner_name,
        document_number: bank.owner_document
      }
    }
  end

  # Transfer amount to payer bank account via transfers API
  def transfer_credits(user)
    raise "user must have credits" if (user.credits == 0) || user.has_pending_legacy_refund?
    PagarMe.api_key = CatarsePagarme.configuration.api_key

    bank_account = PagarMe::BankAccount.new(bank_account_attributes(user).delete(:bank_account))
    bank_account.create
    raise "unable to create an bank account" unless bank_account.id.present?

    transfer = PagarMe::Transfer.new({
      bank_account_id: bank_account.id,
      amount: user.credits_amount
    })
    transfer.create
    raise "unable to create a transfer" unless transfer.id.present?

    #avoid sending notification
    user.user_transfers.create!({
      gateway_id: transfer.id,
      transfer_data: transfer.to_json,
      amount: transfer.amount,
      status: transfer.status
    })
  end

  def perform(user_id)
    user = User.find user_id
    transfer_credits(user)
  end
end
