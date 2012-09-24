class BackerObserver < ActiveRecord::Observer
  observe :backer

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def before_save(backer)
    Notification.notify_backer(backer, :payment_slip) if backer.payment_choice_was.nil? && backer.payment_choice == 'BoletoBancario'
    if backer.confirmed and backer.confirmed_at.nil?
      backer.confirmed_at = Time.now
      Notification.notify_backer(backer, :confirm_backer)
    end
  end
end
