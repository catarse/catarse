ActiveAdmin.register Backer do
  controller.authorize_resource
  scope :confirmed
  scope :not_confirmed
  scope :anonymous
  scope :not_anonymous
  scope :pending
  scope :can_refund
  
  index do
    column :key
    column :user
    column :project
    column :value
    column :payment_method
    default_actions
  end
end