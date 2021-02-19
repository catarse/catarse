# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::AntifraudOrderWrapper do
  let(:attributes) { double }
  let(:transaction) { double }

  subject { described_class.new(attributes, transaction) }

  describe '#send' do
    let(:order) { double }
    let(:client) { double }
    let(:response) { double }
    let(:analyze) { true }

    before do
      allow(subject).to receive(:build_order).with(analyze: analyze).and_return(order)
      allow(subject).to receive(:client).and_return(client)
      allow(client).to receive(:analyze).with(order).and_return(response)
    end

    it 'sends to antifraud' do
      expect(subject.send(analyze: analyze)).to eq response
    end
  end

  describe '#client' do
    context 'when @client is present' do
      it 'returns client' do
        client = double
        subject.instance_variable_set('@client', client)

        expect(subject.__send__(:client)).to eq client
      end
    end

    context 'when @client isn`t present' do
      let(:client) { double }

      before do
        allow(CatarsePagarme).to receive_message_chain('configuration.konduto_api_key').and_return('some-key')
        allow(KondutoRuby).to receive(:new).with('some-key').and_return(client)
      end

      it 'initialize a new client' do
        subject.instance_variable_set('@client', nil)

        expect(subject.__send__(:client)).to eq client
      end
    end
  end

  describe '#build_order' do
    let(:order_attributes) { { total_amount: 10 } }
    let(:customer) { KondutoCustomer.new }
    let(:payment) { [KondutoPayment.new] }
    let(:billing) { KondutoAddress.new }
    let(:shipping) { KondutoAddress.new }
    let(:shopping_cart) { [KondutoItem.new] }
    let(:seller) { KondutoSeller.new }

    before do
      allow(subject).to receive(:order_attributes).and_return(order_attributes)
      allow(subject).to receive(:build_customer).and_return(customer)
      allow(subject).to receive(:build_payment).and_return(payment)
      allow(subject).to receive(:build_billing_address).and_return(billing)
      allow(subject).to receive(:build_shipping_address).and_return(shipping)
      allow(subject).to receive(:build_shopping_cart).and_return(shopping_cart)
      allow(subject).to receive(:build_seller).and_return(seller)
    end

    it 'builds an order' do
      order = subject.__send__(:build_order, analyze: false)
      expect(order.total_amount).to eq order_attributes[:total_amount]
      expect(order.analyze).to eq false
      expect(order.customer).to eq customer
      expect(order.payment).to eq payment
      expect(order.billing).to eq billing
      expect(order.shipping).to eq shipping
      expect(order.shopping_cart).to eq shopping_cart
      expect(order.seller).to eq seller
    end
  end

  describe '#build_customer' do
    let(:customer_attributes) { { name: 'John Appleseed' } }

    before { allow(subject).to receive(:customer_attributes).and_return(customer_attributes) }

    it 'builds a customer' do
      customer = subject.__send__(:build_customer)
      expect(customer.name).to eq customer_attributes[:name]
    end
  end

  describe '#build_payment' do
    let(:payment_attributes) { { bin: '012345' } }

    before { allow(subject).to receive(:payment_attributes).and_return(payment_attributes) }

    it 'builds a payment' do
      payment = subject.__send__(:build_payment)
      expect(payment.first.bin).to eq payment_attributes[:bin]
    end
  end

  describe '#build_billing_address' do
    let(:billing_address_attributes) { { address1: 'R. Tree' } }

    before { allow(subject).to receive(:billing_address_attributes).and_return(billing_address_attributes) }

    it 'builds an address' do
      address = subject.__send__(:build_billing_address)
      expect(address.address1).to eq billing_address_attributes[:address1]
    end
  end

  describe '#build_shipping_address' do
    let(:shipping_address_attributes) { { address1: 'R. Tree' } }

    before { allow(subject).to receive(:shipping_address_attributes).and_return(shipping_address_attributes) }

    it 'builds an address' do
      address = subject.__send__(:build_shipping_address)
      expect(address.address1).to eq shipping_address_attributes[:address1]
    end
  end

  describe '#build_shopping_cart' do
    let(:item_attributes) { { sku: '0102' } }

    before { allow(subject).to receive(:item_attributes).and_return(item_attributes) }

    it 'builds an item' do
      item = subject.__send__(:build_shopping_cart)
      expect(item.first.sku).to eq item_attributes[:sku]
    end
  end

  describe '#build_seller' do
    let(:seller_attributes) { { name: 'Catarse' } }

    before { allow(subject).to receive(:seller_attributes).and_return(seller_attributes) }

    it 'builds a seller' do
      seller = subject.__send__(:build_seller)
      expect(seller.name).to eq seller_attributes[:name]
    end
  end

  describe '#customer_attributes' do
    let(:attributes) do
      {
        customer: {
          id: 123,
          document_number: '1234',
          name: 'John Appleseed',
          email: 'john@example.com',
          phone: { ddi: '85', ddd: '85', number: '85858585' }
        },
        antifraud_metadata: {
          register: {
            registered_at: '2019-01-01 01:01:01'
          }
        }
      }
    end

    before { subject.attributes = attributes }

    it 'builds customer attributes' do
      customer_attributes = subject.__send__(:customer_attributes)

      expect(customer_attributes[:id]).to eq '123'
      expect(customer_attributes[:tax_id]).to eq '1234'
      expect(customer_attributes[:name]).to eq 'John Appleseed'
      expect(customer_attributes[:email]).to eq 'john@example.com'
      expect(customer_attributes[:phone1]).to eq '858585858585'
      expect(customer_attributes[:created_at]).to eq '2019-01-01 01:01:01'
    end
  end

  describe '#payment_attributes' do
    let(:attributes) do
      {
        customer: {
          document_number: '1234',
          name: 'John Appleseed',
          email: 'john@example.com',
          phone: { ddi: '85', ddd: '85', number: '85858585' }
        },
        antifraud_metadata: {
          register: {
            registered_at: '2019-01-01 01:01:01'
          }
        }
      }
    end

    let(:transaction) do
      double(status: 'authorized', card: double(first_digits: '123456', last_digits: '7890', expiration_date: '1122'))
    end

    before do
      subject.attributes = attributes
      subject.transaction = transaction
    end

    it 'builds customer attributes' do
      payment_attributes = subject.__send__(:payment_attributes)

      expect(payment_attributes[:type]).to eq 'credit'
      expect(payment_attributes[:bin]).to eq '123456'
      expect(payment_attributes[:last4]).to eq '7890'
      expect(payment_attributes[:expiration_date]).to eq '112022'
    end

    context 'when transaction status is authorized' do
      it 'build with approved status' do
        payment_attributes = subject.__send__(:payment_attributes)
        expect(payment_attributes[:status]).to eq 'approved'
      end
    end

    context 'when transaction status isn`t authorized' do
      let(:transaction) do
        double(status: 'refused', card: double(first_digits: '123456', last_digits: '7890', expiration_date: '1122'))
      end

      it 'build with declined status' do
        payment_attributes = subject.__send__(:payment_attributes)
        expect(payment_attributes[:status]).to eq 'declined'
      end
    end
  end

  describe '#billing_address_attributes' do
    let(:attributes) do
      {
        customer: {
          name: 'John Appleseed'
        },
        antifraud_metadata: {
          billing: {
            address: {
              street: 'R. A',
              city: 'New City',
              state: 'NC',
              zipcode: '1245',
              country_code: 'BR'
            }
          }
        }
      }
    end

    let(:transaction) { double(card: double(holder_name: 'holder name')) }

    before do
      subject.attributes = attributes
      subject.transaction = transaction
    end

    it 'builds customer attributes' do
      billing_address_attributes = subject.__send__(:billing_address_attributes)

      expect(billing_address_attributes[:name]).to eq 'holder name'
      expect(billing_address_attributes[:address1]).to eq 'R. A'
      expect(billing_address_attributes[:city]).to eq 'New City'
      expect(billing_address_attributes[:state]).to eq 'NC'
      expect(billing_address_attributes[:zip]).to eq '1245'
      expect(billing_address_attributes[:country_code]).to eq 'BR'
    end
  end

  describe '#shipping_address_attributes' do
    let(:attributes) do
      {
        antifraud_metadata: {
          shipping: {
            customer: {
              name: 'John Appleseed'
            },
            address: {
              street: 'R. A',
              city: 'New City',
              state: 'NC',
              zipcode: '1245'
            }
          }
        }
      }
    end

    let(:transaction) { double(card: double) }

    before do
      subject.attributes = attributes
      subject.transaction = transaction
    end

    it 'builds customer attributes' do
      shipping_address_attributes = subject.__send__(:shipping_address_attributes)

      expect(shipping_address_attributes[:name]).to eq 'John Appleseed'
      expect(shipping_address_attributes[:address1]).to eq 'R. A'
      expect(shipping_address_attributes[:city]).to eq 'New City'
      expect(shipping_address_attributes[:state]).to eq 'NC'
      expect(shipping_address_attributes[:zip]).to eq '1245'
    end
  end

  describe '#item_attributes' do
    let(:attributes) do
      {
        amount: 1000,
        metadata: {
          contribution_id: 'contribution-id',
          project_online: '2019-01-01 01:01:01'
        },
        antifraud_metadata: {
          shopping_cart: [
            { name: 'Book' }
          ]
        }
      }
    end

    before { subject.attributes = attributes }

    it 'builds customer attributes' do
      item_attributes = subject.__send__(:item_attributes)

      expect(item_attributes[:sku]).to eq 'contribution-id'
      expect(item_attributes[:product_code]).to eq 'contribution-id'
      expect(item_attributes[:category]).to eq 9999
      expect(item_attributes[:name]).to eq 'Book'
      expect(item_attributes[:unit_cost]).to eq 10.0
      expect(item_attributes[:quantity]).to eq 1
      expect(item_attributes[:created_at]).to eq '2019-01-01'
    end
  end


  describe '#seller_attributes' do
    let(:attributes) do
      {
        antifraud_metadata: {
          events: [
            {
              id: 'event-id',
              venue_name: 'Autor',
              date: '2019-01-01'
            }
          ]
        }
      }
    end

    before { subject.attributes = attributes }

    it 'builds customer attributes' do
      seller_attributes = subject.__send__(:seller_attributes)

      expect(seller_attributes[:id]).to eq 'event-id'
      expect(seller_attributes[:name]).to eq 'Autor'
      expect(seller_attributes[:created_at]).to eq '2019-01-01'
    end
  end
end
