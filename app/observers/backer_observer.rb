class BackerObserver < ActiveRecord::Observer
  observe :backer

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def before_save(backer)
    Notification.create_notification(:payment_slip, backer.user, :backer => backer, :project_name => backer.project.name) if backer.payment_choice_was.nil? && backer.payment_choice == 'BoletoBancario'

    if backer.confirmed and backer.confirmed_at.nil?
      backer.confirmed_at = Time.now
      Notification.create_notification(:confirm_backer, backer.user, :backer => backer,  :project_name => backer.project.name)
    end

    unless backer.user.have_address?
      backer.user.address_street = backer.address_street
      backer.user.address_number = backer.address_number
      backer.user.address_neighbourhood = backer.address_neighbourhood
      backer.user.address_zip_code = backer.address_zip_code
      backer.user.address_city = backer.address_city
      backer.user.address_state = backer.address_state
      backer.user.phone_number = backer.address_phone_number
    end

    unless backer.user.full_name.present?
      backer.user.full_name = backer.payer_name
    end

    backer.user.save
  end

  def after_save(backer)
    Notification.create_notification_once(:project_success, backer.project.user, {'project_id' => backer.project.id}, project: backer.project) if backer.project.successful?
  end

end
