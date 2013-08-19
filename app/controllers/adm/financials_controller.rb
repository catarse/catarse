class Adm::FinancialsController < Adm::BaseController
  require 'csv'
  inherit_resources
  defaults  resource_class: Project, collection_name: 'projects', instance_name: 'project'
  menu I18n.t("adm.financials.index.menu") => Rails.application.routes.url_helpers.adm_financials_path
  has_scope :by_permalink, :name_contains, :user_name_contains, :financial, :by_state, :by_progress
  has_scope :between_expires_at, using: [ :start_at, :ends_at ], allow_blank: true

  actions :index

  def projects
    @search = apply_scopes(Project).includes(:user).order("CASE state WHEN 'successful' THEN 1 WHEN 'waiting_funds' THEN 2 ELSE 3 END, (projects.expires_at)::date DESc")
  end

  def collection
    @projects = projects.page(params[:page])
  end

  def index
    respond_to do |format|
      format.html {collection}
      format.csv do
        csv_string = CSV.generate do |csv|
          # header row
          csv << ["name", "moip", "goal", "reached", "moip_tax", "catarse_fee", "repass_value","expires_at", "backer_report", "state"]
          # data rows
          projects.each do |project|
            catarse_fee = ::Configuration[:catarse_fee].to_f * project.pledged
            csv << [project.name,
                    project.user.moip_login,
                    project.display_goal,
                    "#{project.display_pledged} (#{project.progress}%)",
                    "#{view_context.number_to_currency project.total_payment_service_fee, precision: 2 }",
                    "#{view_context.number_to_currency catarse_fee, precision: 2 } (#{view_context.number_to_currency project.pledged - catarse_fee, precision: 2 })",
                    "#{view_context.number_to_currency project.pledged*0.87, precision: 2 }",
                     "#{project.display_expires_at} (#{I18n.l(8.weekdays_from(project.expires_at).to_date)})",
                     "#{adm_reports_backer_reports_url(project_id: project.id, format: :csv)}",
                     project.state
            ]
          end
        end
        send_data csv_string,
                  type: 'text/csv; charset=iso-8859-1; header=present',
                  disposition: "attachment; filename=financials.csv"
      end
    end
  end

end
