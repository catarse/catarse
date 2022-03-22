# frozen_string_literal: true

module Projects
  class ProjectFiscalController < ApplicationController
    before_action :set_date, only: [:inform]
    before_action :set_project, only: %i[inform inform_years]

    inherit_resources
    actions :show
    belongs_to :project

    def debit_note
      project_fiscal = ProjectFiscal.find_by(id: params[:id])

      if project_fiscal.blank?
        redirect_to edit_project_path(params[:project_id], locale: nil)
      else
        authorize project_fiscal
        render(
          'user_notifier/mailer/project_fiscal_debit_note',
          locals: { project_fiscal: project_fiscal },
          layout: 'layouts/email'
        )
      end
    end

    def inform
      project_fiscals = project_fiscals_to_informs

      if project_fiscals.blank?
        redirect_to edit_project_path(params[:project_id], locale: nil)
      else
        authorize project_fiscals.first
        render(
          'user_notifier/mailer/project_fiscal_inform',
          locals: { project_fiscals: project_fiscals },
          layout: 'layouts/email'
        )
      end
    end

    def inform_years
      project_fiscal = ProjectFiscal.find_by(project_id: params[:project_id])
      authorize project_fiscal if project_fiscal.present?

      result = ProjectFiscal.select("DATE_PART('year', end_date) as year")
        .where(project_id: params[:project_id], end_date: ...Time.zone.now.beginning_of_year).distinct.map(&:year)

      render json: { result: result }
    end

    def debit_note_end_dates
      project_fiscals = Project.find(params[:project_id])&.project_fiscals
      authorize project_fiscals.first if project_fiscals.present?
      result = []

      project_fiscals.each do |project_fiscal|
        result << {
          project_fiscal_id: project_fiscal.id,
          project_id: project_fiscal.project_id,
          end_date: I18n.l(project_fiscal.end_date.to_date)
        }
      end
      render json: { result: result }
    end

    private

    def set_date
      @begin_date = "01/#{params[:fiscal_year]}".to_date.beginning_of_month
      @end_date = "12/#{params[:fiscal_year]}".to_date.end_of_month
    end

    def set_project
      @project = Project.find(params[:project_id])
    end

    def project_fiscals_to_informs
      return project_fiscals_from_sub_project if @project.is_sub?

      project_fiscals_from_not_sub_project
    end

    def project_fiscals_from_sub_project
      ProjectFiscal.where(
        'project_id = :project_id AND begin_date >= :begin_date AND end_date <= :end_date',
        project_id: params[:project_id], begin_date: @begin_date, end_date: @end_date
      )
    end

    def project_fiscals_from_not_sub_project
      last_end_date = ProjectFiscal.where(project_id: params[:project_id]).last&.end_date
      return if last_end_date.try(:year).nil? || last_end_date.try(:year) < params[:fiscal_year].to_i

      ProjectFiscal.where(
        'project_id = :project_id AND end_date <= :end_date', project_id: params[:project_id], end_date: @end_date
      )
    end
  end
end
