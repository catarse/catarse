# frozen_string_literal: true

class Projects::ProjectFiscalDataController < ApplicationController
  inherit_resources
  actions :show
  belongs_to :project


  def debit_note
    fiscal_data = ProjectFiscalData.find_by(project_id: params[:project_id], fiscal_date: params[:fiscal_date])
    if !fiscal_data.nil?
      authorize fiscal_data
      template = 'project_debit_note'
      render "user_notifier/mailer/#{template}", locals: { fiscal_data:fiscal_data }, layout: 'layouts/email'
    else
      redirect_to edit_project_path(params[:project_id], locale: nil)
    end
  end


  def inform
    fiscal_data = ProjectFiscalInform.find_by(project_id: params[:project_id], fiscal_year: params[:fiscal_year])
    if !fiscal_data.nil?
      authorize fiscal_data
      template = 'project_inform'
      render "user_notifier/mailer/#{template}", locals: { fiscal_data:fiscal_data }, layout: 'layouts/email'
    else
      redirect_to edit_project_path(params[:project_id], locale: nil)
    end
  end
end
