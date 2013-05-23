class Reports::BackerReportsForProjectOwnersController < Reports::BaseController
  before_filter :check_if_project_belongs_to_user

  def end_of_association_chain
    conditions = { project_id: params[:project_id] }

    conditions.merge!(reward_id: params[:reward_id]) if params[:reward_id].present?

    super.
      select(%Q{
        reward_description as "#{I18n.t('backer_report_to_project_owner.reward_description')}",
        confirmed_at as "#{I18n.t('backer_report_to_project_owner.confirmed_at')}",
        back_value as "#{I18n.t('backer_report_to_project_owner.value')}",
        service_fee as "#{I18n.t('backer_report_to_project_owner.service_fee')}",
        user_name as "#{I18n.t('backer_report_to_project_owner.user_name')}",
        user_email as "#{I18n.t('backer_report_to_project_owner.user_email')}",
        payer_email as "#{I18n.t('backer_report_to_project_owner.payer_email')}",
        payment_method as "#{I18n.t('backer_report_to_project_owner.payment_method')}",
        street as "#{I18n.t('backer_report_to_project_owner.address_street')}",
        complement as "#{I18n.t('backer_report_to_project_owner.address_complement')}",
        address_number as "#{I18n.t('backer_report_to_project_owner.address_number')}",
        neighbourhood as "#{I18n.t('backer_report_to_project_owner.address_neighbourhood')}",
        city as "#{I18n.t('backer_report_to_project_owner.address_city')}",
        state as "#{I18n.t('backer_report_to_project_owner.address_state')}",
        zip_code as "#{I18n.t('backer_report_to_project_owner.address_zip_code')}",
        CASE WHEN anonymous='t' THEN '#{I18n.t('yes')}'
            WHEN anonymous='f' THEN '#{I18n.t('no')}'
        END as "#{I18n.t('backer_report_to_project_owner.anonymous')}"
      }).
      where(conditions)
  end

  def check_if_project_belongs_to_user
    redirect_to root_path unless can? :update, Project.find(params[:project_id])
  end
end
