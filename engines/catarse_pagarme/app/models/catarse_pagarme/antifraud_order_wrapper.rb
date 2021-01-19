module CatarsePagarme
  class AntifraudOrderWrapper
    attr_accessor :attributes, :transaction

    def initialize(attributes, transaction)
      self.attributes = attributes
      self.transaction = transaction
    end

    def send(analyze:)
      order = build_order(analyze: analyze)
      client.analyze(order)
    end

    private

    def client
      konduto_api_key = CatarsePagarme.configuration.konduto_api_key
      @client ||= KondutoRuby.new(konduto_api_key)
    end

    def build_order(analyze:)
      KondutoOrder.new(
        order_attributes.merge({
          analyze: analyze,
          customer: build_customer,
          payment: build_payment,
          billing: build_billing_address,
          shipping: build_shipping_address,
          shopping_cart: build_shopping_cart,
          seller: build_seller
        })
      )
    end

    def build_customer
      KondutoCustomer.new(customer_attributes)
    end

    def build_payment
      [KondutoPayment.new(payment_attributes)]
    end

    def build_billing_address
      KondutoAddress.new(billing_address_attributes)
    end

    def build_shipping_address
      KondutoAddress.new(shipping_address_attributes)
    end

    def build_shopping_cart
      [KondutoItem.new(item_attributes)]
    end

    def build_seller
      KondutoSeller.new(seller_attributes)
    end

    def order_attributes
      {
        id: self.transaction.id.to_s[0..99],
        total_amount: self.attributes[:amount] / 100.0,
        visitor: self.attributes.dig(:metadata, :contribution_id).to_s[0..40],
        currency: 'BRL',
        installments: self.attributes[:installments],
        purchased_at: self.transaction.date_created,
        ip: self.attributes.dig(:antifraud_metadata, :ip)
      }
    end

    def customer_attributes
      customer = self.attributes.dig(:customer)
      tax_id = customer[:document_number].present? ? { tax_id: customer[:document_number] } : {}

      {
        id: customer[:id].to_s[0..99],
        name: customer[:name].to_s[0..99],
        email: customer[:email].to_s[0..99],
        phone1: customer[:phone].to_h.values.join.to_s[0..99],
        created_at: self.attributes.dig(:antifraud_metadata, :register, :registered_at)
      }.merge(tax_id)
    end

    def payment_attributes
      {
        type: 'credit',
        status: self.transaction.status == 'authorized' ? 'approved' : 'declined',
        bin: self.transaction.card.first_digits,
        last4: self.transaction.card.last_digits,
        expiration_date: card_expiration_date
      }
    end

    def billing_address_attributes
      billing_data = self.attributes.dig(:antifraud_metadata, :billing)
      {
        name: self.transaction.card.holder_name.to_s[0..99],
        address1: billing_data.dig(:address, :street).to_s[0..254],
        city: billing_data.dig(:address, :city).to_s[0..99],
        state: billing_data.dig(:address, :state).to_s[0..99],
        zip: billing_data.dig(:address, :zipcode).to_s[0..99],
        country: billing_data.dig(:address, :country_code).to_s[0..1],
      }
    end

    def shipping_address_attributes
      shipping_data = self.attributes.dig(:antifraud_metadata, :shipping)
      {
        name: shipping_data.dig(:customer, :name).to_s[0..99],
        address1: shipping_data.dig(:address, :street).to_s[0..254],
        city: shipping_data.dig(:address, :city).to_s[0..99],
        state: shipping_data.dig(:address, :state).to_s[0..99],
        zip: shipping_data.dig(:address, :zipcode).to_s[0..99]
      }
    end

    def item_attributes
      shopping_cart_data = self.attributes.dig(:antifraud_metadata, :shopping_cart).first
      {
        sku: self.attributes.dig(:metadata, :contribution_id).to_s[0..99],
        product_code: self.attributes.dig(:metadata, :contribution_id).to_s[0..99],
        category: 9999,
        name: shopping_cart_data[:name].to_s[0..99],
        unit_cost: self.attributes[:amount] / 100.0,
        quantity: 1,
        created_at: self.attributes.dig(:metadata, :project_online).to_s[0..9]
      }
    end

    def seller_attributes
      event_data = self.attributes.dig(:antifraud_metadata, :events).first
      {
        id: event_data[:id].to_s[0..99],
        name: event_data[:venue_name].to_s[0..99],
        created_at: event_data[:date]
      }
    end

    def card_expiration_date
      expiration_date = self.transaction.card.expiration_date
      "#{expiration_date[0..1]}20#{expiration_date[2..3]}"
    end
  end
end
