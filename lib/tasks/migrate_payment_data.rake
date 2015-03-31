desc "Migrate payments data using first payment notification"
task :migrate_payment_data => :environment do
  payments = Payment.order(id: :desc)

  payments.each do |payment|
    first_notification = PaymentNotification.where(payment_id: payment.id).order(:id).first
    if first_notification.present?
      data = first_notification.extra_data
      data = JSON.parse(first_notification.extra_data) if data.kind_of? String
      if data.present?
        contribution = Contribution.find(payment.id)
        data["tid"] = contribution.acquirer_tid
        data["acquirer_name"] = contribution.acquirer_name
        data["card_brand"] = contribution.card_brand
        data["boleto_url"] = contribution.slip_url

        payment.gateway_data = data
        if payment.save
          puts "Saved data for payment #{payment.id}"
        else
          puts "Error saving data"
        end
      end
    end
  end
end

