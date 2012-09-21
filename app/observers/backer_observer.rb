class BackerObserver < ActiveRecord::Observer
  observe :backer

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def before_save(backer)
    if backer.confirmed and backer.confirmed_at.nil?
      backer.confirmed_at = Time.now
      nt = NotificationType.where(:name => 'confirm_backer').first
      Notification.notify_backer(backer, nt) if nt
    end
  end
end
