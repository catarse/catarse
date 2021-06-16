# frozen_string_literal: true

class GatewayPaymentSync
  include Rake::DSL
  def initialize
    namespace :cache do
      task gateway_payments_sync: :environment do
        PagarMe.api_key = CatarsePagarme.configuration.api_key
        ActiveRecord::Base.connection_pool.with_connection do
          call
        end
      end
    end
  end

  private

  def call
    page = 1
    loop do
      transactions = fetch_transactions(page: page, per_page: 500)
      break if transactions.blank? || Rails.env.test?

      import_gateway_payments(transactions)
      page += 1
      sleep 1
    end
  rescue StandardError => e
    handle_error(e)
  end

  def fetch_transactions(page:, per_page:)
    Rails.logger.info "[GatewayPayment SYNC] -> running on page #{page}"
    transactions = PagarMe::Transaction.all(page, per_page)

    transactions_response(transactions, page)
  rescue StandardError => e
    handle_error(e)
  end

  def import_gateway_payments(transactions)
    transactions.each do |transaction|
      update_or_create_gateway_payment(transaction)
    end
  end

  def update_or_create_gateway_payment(transaction)
    retries ||= 0
    gateway_payment = GatewayPayment.find_or_create_by transaction_id: transaction.id.to_s
    gateway_payment_response_update(gateway_payment, transaction)
  rescue RestClient::BadGateway => e
    return handle_error(e) if retries > 3

    retries += 1
    sleep 3
    retry
  rescue StandardError => e
    handle_error(e)
  end

  def gateway_payment_response_update(gateway_payment, transaction)
    gateway_payment.update(
      gateway_data: transaction.to_json,
      postbacks: parse_json(transaction.postbacks),
      payables: parse_json(transaction.payables),
      events: parse_json(transaction.events),
      operations: parse_json(transaction.operations),
      last_sync_at: Time.zone.now
    )
  end

  def transactions_response(transactions, page)
    if transactions.empty?
      Rails.logger.info '[GatewayPayment SYNC] -> exiting no transactions returned'
      nil
    else
      Rails.logger.info "[GatewayPayment SYNC] - transactions synced on page #{page}"
      transactions
    end
  end

  def parse_json(data)
    data.to_json
  rescue StandardError
    nil
  end

  def handle_error(error)
    Sentry.capture_exception(error, extra: { task: :gateway_payments_sync })
  end
end

GatewayPaymentSync.new
