class Reports::ContributionReportsForProjectOwnersController < ApplicationController
  inherit_resources
  respond_to :csv, :xls
  actions :index

  #TODO Refact to use pudint
  def index
    @report = end_of_association_chain.to_xls( columns: I18n.t('contribution_report_to_project_owner').values )
    @project = Project.find params[:project_id]

    super do |format|
      format.csv { send_data end_of_association_chain.copy_to_string, filename: "#{@project.name}.csv" }
      format.xls { send_data @report, filename: "#{@project.name}.xls" }
    end
  end

  def end_of_association_chain
    report_sql = ""
    I18n.t('contribution_report_to_project_owner').keys[0..-2].each{
      |column| report_sql << "#{column} AS \"#{I18n.t("contribution_report_to_project_owner.#{column}")}\","
    }

    super.
      select(%Q{
        #{report_sql}
        CASE WHEN anonymous='t' THEN '#{I18n.t('yes')}'
            WHEN anonymous='f' THEN '#{I18n.t('no')}'
        END as "#{I18n.t('contribution_report_to_project_owner.anonymous')}"
      }).
      where(get_conditions)
  end

  def get_conditions
    conditions = { project_id: params[:project_id] }

    conditions.merge!(reward_id: params[:reward_id]) if params[:reward_id].present?
    conditions.merge!(state: (params[:state].present? ? params[:state] : 'paid'))
    conditions.merge!(project_owner_id: current_user.id) unless current_user.admin

    conditions
  end
end
