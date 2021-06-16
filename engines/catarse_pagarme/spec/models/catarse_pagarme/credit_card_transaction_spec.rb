# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::CreditCardTransaction do
  let(:payment) { create(:payment, value: 100) }

  let(:valid_attributes) do
      {
        payment_method: 'credit_card',
        card_number: '4901720080344448',
        card_holder_name: 'Foo bar',
        card_expiration_month: '10',
        card_expiration_year: '19',
        card_cvv: '434',
        amount: payment.pagarme_delegator.value_for_transaction,
        postback_url: 'http://test.foo',
        installments: 1
      }
  end

  let(:card_transaction) { CatarsePagarme::CreditCardTransaction.new(valid_attributes, payment) }

  before do
    # PagarMe::Transaction.stub(:new).and_return(pagarme_transaction)
    CatarsePagarme::PaymentDelegator.any_instance.stub(:change_status_by_transaction).and_return(true)
    CatarsePagarme.configuration.stub(:credit_card_tax).and_return(0.01)
  end

  describe '#process!' do
    let(:transaction) { double(status: 'refused') }

    before do
      allow(card_transaction).to receive(:transaction).and_return(transaction)
      allow(card_transaction).to receive(:authorize!).and_return(true)
      allow(card_transaction).to receive(:change_payment_state).and_return(true)
    end

    it 'authorizes transaction' do
      expect(card_transaction).to receive(:authorize!)
      card_transaction.process!
    end

    context 'when transaction is authorized' do
      let(:transaction) { double(status: 'authorized', capture: true, refund: true) }

      context 'when credit card was used before' do
        before { allow(card_transaction).to receive(:was_credit_card_used_before?).and_return(true) }

        it 'captures transaction' do
          expect(card_transaction.transaction).to receive(:capture)

          card_transaction.process!
        end
      end

      context 'when is a new credit credit card' do
        let(:antifraud_outcome) { double(recommendation: :APPROVE) }

        before do
          allow(card_transaction).to receive(:was_credit_card_used_before?).and_return(false)
          allow(card_transaction).to receive(:process_antifraud).and_return(antifraud_outcome)
        end

        it 'processes antifraud' do
          expect(card_transaction).to receive(:process_antifraud)

          card_transaction.process!
        end

        context 'when antifraud recommends approve transaction' do
          let(:antifraud_outcome) { double(recommendation: :APPROVE) }

          it 'captures transaction' do
            expect(card_transaction.transaction).to receive(:capture)

            card_transaction.process!
          end
        end

        context 'when antifraud recommends decline transaction' do
          let(:antifraud_outcome) { double(recommendation: :DECLINE) }

          it 'refunds transaction' do
            expect(card_transaction.transaction).to receive(:refund)

            card_transaction.process!
          end
        end

        context 'when antifraud recommends review transaction' do
          let(:antifraud_outcome) { double(recommendation: :REVIEW) }

          it 'notifies about pending review' do
            expect(card_transaction.payment).to receive(:notify_about_pending_review)

            card_transaction.process!
          end
        end
      end
    end

    it 'changes payment state' do
      expect(card_transaction).to receive(:change_payment_state)

      card_transaction.process!
    end
  end

  describe '#authorize!' do
    let(:attributes) do
      {
        amount: 10,
        card_hash: 'capgojepaogejpeoajgpeaoj124pih3p4h32p',
        postback_url: 'https://example.com/postback',
        installments: 2,
        soft_descriptor: 'Catarse Test'
      }
    end

    let(:transaction) do
      PagarMe::Transaction.new(
        amount: attributes[:amount],
        card_hash: attributes[:card_hash],
        capture: false,
        async: false,
        postback_url: attributes[:postback_url],
        installments: 2,
        soft_descriptor: 'Catarse Test'
    )
    end

    before do
      card_transaction.attributes = attributes
      allow_any_instance_of(PagarMe::Transaction).to receive(:charge).and_return(true)
      allow(card_transaction).to receive(:change_payment_state).and_return(true)
    end

    it 'build a new pagarme transaction' do
      transaction_attributes = {
        amount: attributes[:amount],
        card_hash: attributes[:card_hash],
        capture: false,
        async: false,
        postback_url: attributes[:postback_url],
        installments: attributes[:installments],
        soft_descriptor: attributes[:soft_descriptor]
      }

      allow(PagarMe::Transaction).to receive(:new).with(transaction_attributes).and_return(transaction)

      card_transaction.authorize!

      expect(card_transaction.transaction).to eq transaction
    end

    context 'when a saved credit card is used' do
      let(:attributes) { { card_id: 'card_eaoj124pih3p4h32p' } }

      it 'uses card id instead card hash' do
        card_transaction.attributes = attributes

        expect(card_transaction.send(:credit_card_identifier)).to eq(card_id: 'card_eaoj124pih3p4h32p')
      end
    end

    it 'updates payment gateway and payment_method' do
      card_transaction.authorize!

      expect(payment.gateway).to eq 'Pagarme'
      expect(payment.payment_method).to eq 'CartaoDeCredito'
    end

    it 'charges transaction' do
      allow(PagarMe::Transaction).to receive(:new).and_return(transaction)
      expect(transaction).to receive(:charge)

      card_transaction.authorize!
    end

    it 'changes payment state' do
      expect(card_transaction).to receive(:change_payment_state)

      card_transaction.authorize!
    end

    context 'when transaction status is refused' do
      before do
        allow_any_instance_of(PagarMe::Transaction).to receive(:status).and_return('refused')
        allow(card_transaction.antifraud_wrapper).to receive(:send).with(analyze: false).and_return(true)
      end

      it 'sends to antifraud' do
        expect(card_transaction.antifraud_wrapper).to receive(:send).with(analyze: false)

        card_transaction.authorize! rescue nil
      end

      it 'raises PagarMeError exception' do
        expect do
          card_transaction.authorize!
        end.to raise_error(PagarMe::PagarMeError)
      end
    end

    context 'when save_card attribute is true' do
      it 'saves credit card' do
        card_transaction.attributes[:save_card] = true
        expect(card_transaction).to receive(:save_user_credit_card)

        card_transaction.authorize!
      end
    end

    context 'when save_card attribute is false' do
      it 'does`t save credit card' do
        card_transaction.attributes[:save_card] = false
        expect(card_transaction).to_not receive(:save_user_credit_card)

        card_transaction.authorize!
      end
    end
  end

  describe '#was_credit_card_used_before?' do
    let(:transaction) { double(card: double(id: '123')) }

    before { card_transaction.transaction = transaction }

    context 'when credit card was used before' do
      before do
        allow(PaymentEngines).to receive(:was_credit_card_used_before?)
          .with(transaction.card.id)
          .and_return(true)
      end

      it 'returns true' do
        expect(card_transaction.was_credit_card_used_before?).to be_truthy
      end
    end

    context 'when credit card wasn`t used before' do
      before do
        allow(PaymentEngines).to receive(:was_credit_card_used_before?)
          .with(transaction.card.id)
          .and_return(false)
      end

      it 'returns false' do
        expect(card_transaction.was_credit_card_used_before?).to be_falsey
      end
    end
  end

  describe '#process_antifraud' do
    it 'sends antifraud order' do
      expect(card_transaction.antifraud_wrapper).to receive(:send).with(analyze: true).once

      card_transaction.process_antifraud
    end

    context 'when there is an error' do
      let(:exception) { RuntimeError.new('Error') }
      before { allow(card_transaction.antifraud_wrapper).to receive(:send).and_raise(exception) }

      it 'captures exception with Sentry' do
        expect(Sentry).to receive(:capture_exception).with(exception, { level: :fatal })

        card_transaction.process_antifraud
      end

      it 'returns a struct with decline recommendation' do
        outcome = card_transaction.process_antifraud

        expect(outcome.recommendation).to eq :DECLINE
      end
    end
  end

  describe '#antifraud_wrapper' do
    let(:antifraud_wrapper) { double }

    context 'when @antifraud_wrapper isn`t nil' do
      it 'returns @antifraud_wrapper' do
        card_transaction.instance_variable_set('@antifraud_wrapper', antifraud_wrapper)
        expect(card_transaction.antifraud_wrapper).to eq antifraud_wrapper
      end
    end

    context 'when @antifraud_wrapper is nil' do
      let(:transaction) { double }

      before do
        card_transaction.instance_variable_set('@antifraud_wrapper', nil)
        card_transaction.transaction = transaction
        allow(CatarsePagarme::AntifraudOrderWrapper).to receive(:new)
          .with(valid_attributes, transaction)
          .and_return(antifraud_wrapper)
      end

      it 'returns a new antifraud order wrapper' do
        expect(card_transaction.antifraud_wrapper).to eq antifraud_wrapper
      end
    end
  end
end
