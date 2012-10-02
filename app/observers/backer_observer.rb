class BackerObserver < ActiveRecord::Observer
  observe :backer

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def project_success_mail_not_sent(backer)
    Notification.where(:project_id => backer.project, :notification_type_id => Notification.find_notification(:project_success)).empty?
  end

  def before_save(backer)
    Notification.notify_backer(backer, :payment_slip) if backer.payment_choice_was.nil? && backer.payment_choice == 'BoletoBancario'

    if backer.confirmed and backer.confirmed_at.nil?
      backer.confirmed_at = Time.now
      Notification.notify_backer(backer, :confirm_backer)
    end

    Notification.notify_project_owner(backer.project, :project_success) if backer.project.successful? &&  project_success_mail_not_sent(backer)

    unless user.have_address?
      user.address_street = address_street
      user.address_number = address_number
      user.address_neighbourhood = address_neighbourhood
      user.address_zip_code = address_zip_code
      user.address_city = address_city
      user.address_state = address_state
      user.phone_number = address_phone_number
    end

    unless user.full_name.present?
      user.full_name = payer_name
    end

    user.save
  end
end
