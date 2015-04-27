class Projects::ContributionDetailsController < ApplicationController
  has_scope :available_to_count, type: :boolean
  has_scope :pending, type: :boolean
  has_scope :page, default: 1

  def index
    render collection
  end

  def collection
    @contributions ||= apply_scopes(parent.contribution_details).available_to_display.order("created_at DESC").per(10)
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end

