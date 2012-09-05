class PaymentNotification < ActiveRecord::Base
  belongs_to :backer
  serialize :extra_data, JSON

  after_save :refund_backer
  after_save :confirm_backer

  protected
  def confirm_backer
    backer.confirm! if self.status == 'confirmed'
  end

  def refund_backer
    backer.update_attributes({refunded: true}) if self.status == 'refunded'
  end
end
