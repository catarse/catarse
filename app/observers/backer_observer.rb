class BackerObserver < ActiveRecord::Observer
  observe :backer

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def before_save(backer)
    Notification.create_notification_once(:payment_slip,
      backer.user,
      {backer_id: backer.id},
      backer: backer,
      project_name: backer.project.name) if backer.payment_choice_was.nil? && backer.payment_choice == 'BoletoBancario'

    if backer.confirmed? and backer.confirmed_at.nil?
      backer.confirmed_at = Time.now
      Notification.create_notification_once(:confirm_backer,
        backer.user,
        {backer_id: backer.id},
        backer: backer,
        project_name: backer.project.name)

      Notification.create_notification_once(:project_owner_backer_confirmed,
        backer.project.user,
        {backer_id: backer.id},
        backer: backer,
        project_name: backer.project.name)

      if (Time.now > backer.project.expires_at  + 7.days) && (user = User.where(email: ::Configuration[:email_payments]).first)
        Notification.create_notification_once(:backer_confirmed_after_project_was_closed,
          user,
          {backer_id: backer.id},
          backer: backer,
          project_name: backer.project.name)
      end
    end

    backer.user.address_street = backer.address_street
    backer.user.address_number = backer.address_number
    backer.user.address_neighbourhood = backer.address_neighbourhood
    backer.user.address_zip_code = backer.address_zip_code
    backer.user.address_city = backer.address_city
    backer.user.address_state = backer.address_state
    backer.user.phone_number = backer.address_phone_number
    backer.user.cpf = backer.payer_document

    unless backer.user.full_name.present?
      backer.user.full_name = backer.payer_name
    end

    backer.user.save
  end

  def after_save(backer)
    Notification.create_notification_once(:project_success,
      backer.project.user,
      {project_id: backer.project.id},
      project: backer.project) if backer.project.reached_goal?
  end

  def notify_backoffice(backer)
    CreditsMailer.request_refund_from(backer).deliver
  end

  def notify_backoffice_about_canceled(backer)
    user = User.where(email: Configuration[:email_payments]).first
    if user.present?
      Notification.create_notification_once(:backer_canceled_after_confirmed,
        user,
        {backer_id: backer.id},
        backer: backer)
    end
  end

end
