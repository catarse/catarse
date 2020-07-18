class ImportMissingPayablesTask
  include Rake::DSL

  def initialize
    namespace :payments do
      task import_missing_payables: :environment do
        call
      end
    end
  end

  private

  def call
    PagarMe.api_key = CatarsePagarme.configuration.api_key

    Payment
      .with_missing_payables
      .where('payments.created_at >= ?', Time.zone.parse('2019-01-01'))
      .find_each(batch_size: 200) do |payment|

      p "FETCHING PAYABLES FOR PAYMENT #{payment.id}"

      ImportMissingPayablesAction.new(payment: payment).call

      sleep 1
    end
  end
end
