ActiveAdmin.register Backer do
  controller.authorize_resource
  scope :confirmed
  scope :not_confirmed
  scope :anonymous
  scope :not_anonymous
  scope :pending
  scope :can_refund

  filter :project
  filter :requested_refund
  filter :refunded
  filter :created_at
  filter :confirmed_at

  index do
    column :key
    column :user
    column :project
    column :value
    column :payment_method
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :requested_refund
      f.input :can_refund
      f.input :refunded
      f.input :value
    end
    
    f.buttons do
      f.submit
    end
  end
end