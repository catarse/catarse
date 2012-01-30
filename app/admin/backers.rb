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

  member_action :cancel_refund_request, :method => :put do
    backer = Backer.find(params[:id])
    backer.cancel_refund_request!
    redirect_to :action => :show, :notice => I18n.t('cancel_refund')
  end

  member_action :request_refund, :method => :put do
    backer = Backer.find(params[:id])
    backer.refund!
    redirect_to :action => :show, :notice => I18n.t('cancel_refund')
  end

  show do
    div :class => "panel_contents" do
      div :class => "attributes_table backer" do
        table do
          tbody do
            tr do
              th I18n.t('backer.key')
              td backer.key
            end
            tr do
              th I18n.t('activerecord.models.user')
              td link_to backer.user.name, backer.user
            end
            tr do
              th I18n.t('activerecord.models.project')
              td link_to backer.project.name, backer.project
            end
            tr do
              th I18n.t('backer.value')
              td backer.value
            end
            tr do
              th I18n.t('backer.requested_refund')
              td backer.requested_refund ? I18n.t('yes') : I18n.t('no')
            end
            tr do
              th I18n.t('backer.refunded')
              td backer.refunded ? I18n.t('yes') : I18n.t('no')
            end
          end
        end
      end
      div do
        if backer.requested_refund and not backer.refunded
          link_to I18n.t('backer.cancel_refund_request'), cancel_refund_request_admin_backer_path(backer), :method => :put
        elsif not backer.requested_refund
          link_to I18n.t('backer.refund_request'), request_refund_admin_backer_path(backer), :method => :put
        end
      end
    end
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