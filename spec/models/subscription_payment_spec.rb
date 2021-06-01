# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPayment, type: :model do
  describe '#refund' do
    let(:gateway_id) { '123' }
    let(:subscription_payment) { described_class.new(gateway_general_data: { gateway_id: gateway_id }) }
    let(:transaction) { double(status: 'paid', refund: true, payment_method: 'credit_card') } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(PagarMe::Transaction).to receive(:find).with(gateway_id).and_return(transaction)
      allow(subscription_payment).to receive(:remove_payment_user_balance)
      allow(subscription_payment).to receive(:add_amount_subscriber_balance)
      allow(subscription_payment).to receive(:update_payment_status)
    end

    context 'when transaction is paid with credit_card as the payment_method' do
      it 'refunds on pagarme' do
        expect(transaction).to receive(:refund)

        subscription_payment.refund
      end
    end

    context 'when transaction isn`t paid with credit_card as the payment_method' do
      before do
        allow(transaction).to receive(:status).and_return('refunded')
      end

      it 'doesn`t refund on pagarme' do
        expect(transaction).not_to receive(:refund)

        subscription_payment.refund
      end
    end

    context 'when transaction is paid with boleto as the payment_method' do
      before { allow(transaction).to receive(:payment_method).and_return('boleto') }

      it 'doesn`t refund on pagarme' do
        expect(transaction).not_to receive(:refund)

        subscription_payment.refund
      end
    end

    it 'removes payment amount from user balance' do
      expect(subscription_payment).to receive(:remove_payment_user_balance)

      subscription_payment.refund
    end

    context 'when payment method is boleto' do
      before { allow(transaction).to receive(:payment_method).and_return('boleto') }

      it 'adds amount to subscriber balance' do
        expect(subscription_payment).to receive(:add_amount_subscriber_balance)

        subscription_payment.refund
      end
    end

    context 'when payment method isn`t boleto' do
      let(:transaction) { double(status: 'paid', refund: true, payment_method: 'pix') } # rubocop:disable RSpec/VerifiedDoubles

      it 'doesn`t add amount to subscriber balance' do
        expect(subscription_payment).not_to receive(:add_amount_subscriber_balance)

        subscription_payment.refund
      end
    end

    it 'updates payment status' do
      expect(subscription_payment).to receive(:update_payment_status)

      subscription_payment.refund
    end
  end

  # Private functions

  describe '#remove_payment_user_balance' do
    let(:amount) { 100 }
    let(:fee) { 0.13 }
    let(:amount_to_remove) { ((amount - (amount * fee)) * -1) }
    let(:project_user_id) { 456 }
    let(:subscription_payment) do
      described_class.new(project: Project.new(service_fee: fee, user_id: project_user_id))
    end

    before do
      allow(subscription_payment).to receive(:amount).and_return(amount)
      allow(subscription_payment).to receive(:add_balance_transaction)
    end

    it 'adds a transaction removing the amount from user`s balance' do
      expect(subscription_payment).to receive(:add_balance_transaction)
        .with(user_id: project_user_id, amount: amount_to_remove)

      subscription_payment.send(:remove_payment_user_balance)
    end
  end

  describe '#add_amount_subscriber_balance' do
    let(:amount) { 100 }
    let(:user_id) { 123 }
    let(:subscription_payment) { described_class.new(user: User.new(id: user_id)) }

    before do
      allow(subscription_payment).to receive(:amount).and_return(amount)
      allow(subscription_payment).to receive(:add_balance_transaction)
    end

    it 'adds a transaction adding the amount to subscriber balance' do
      expect(subscription_payment).to receive(:add_balance_transaction).with(user_id: user_id, amount: amount)

      subscription_payment.send(:add_amount_subscriber_balance)
    end
  end

  describe '#add_balance_transaction' do
    let(:amount) { 100 }
    let(:user_id) { 123 }
    let(:id) { SecureRandom.uuid }
    let(:project) { Project.new }
    let(:subscription_payment) { described_class.new(id: id, project: project) }

    before do
      allow(subscription_payment).to receive(:amount).and_return(amount)
      allow(BalanceTransaction).to receive(:create)
    end

    context 'when it wasn`t refunded already' do
      it 'adds a transaction adding the amount to subscriber balance' do
        expect(BalanceTransaction).to receive(:create)
          .with(user_id: user_id, event_name: 'subscription_payment_refunded',
                amount: amount, subscription_payment_uuid: id, project_id: project.id
               )

        subscription_payment.send(:add_balance_transaction, user_id: user_id, amount: amount)
      end
    end

    context 'when it was already refunded' do
      before do
        allow(BalanceTransaction).to receive(:where)
          .with(event_name: 'subscription_payment_refunded', subscription_payment_uuid: id, user_id: user_id)
          .and_return(true)
      end

      it 'doesn`t add a transaction adding the amount to subscriber balance' do
        expect(BalanceTransaction).not_to receive(:create)

        subscription_payment.send(:add_balance_transaction, user_id: user_id, amount: amount)
      end
    end
  end

  describe '#refunded?' do
    let(:user) { create(:user) }
    let(:id) { SecureRandom.uuid }
    let(:subscription_payment) { described_class.new(id: id) }

    context 'when it doesn`t have a refund transation' do
      it 'returns false' do
        expect(subscription_payment.send(:refunded?, user_id: user.id)).to be false
      end
    end

    context 'when it has a refund transation' do
      before do
        create(:balance_transaction,
          event_name: 'subscription_payment_refunded',
          subscription_payment_uuid: id, user: user
        )
      end

      it 'returns true' do
        expect(subscription_payment.send(:refunded?, user_id: user.id)).to be true
      end
    end
  end

  describe '#update_payment_status' do
    let(:subscription_payment) { described_class.new }
    let(:common_wrapper) { double(refund_subscription_payment: true) } # rubocop:disable RSpec/VerifiedDoubles

    before { allow(CommonWrapper).to receive(:new).and_return(common_wrapper) }

    it 'updates the payment status' do
      expect(common_wrapper).to receive(:refund_subscription_payment).with(subscription_payment)

      subscription_payment.send(:update_payment_status)
    end
  end
end
