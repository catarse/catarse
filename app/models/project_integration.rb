# coding: utf-8
# frozen_string_literal: true

class ProjectIntegration < ApplicationRecord
  INTEGRATIONS_AVAILABLE = %w[GA PIXEL SOLIDARITY_SERVICE_FEE COMING_SOON_LANDING_PAGE]

  include I18n::Alchemy

  belongs_to :project

  validates :name, inclusion: { in: INTEGRATIONS_AVAILABLE }
  validate :can_activate_coming_soon

  scope :coming_soon, ->() {
    where("project_integrations.name = 'COMING_SOON_LANDING_PAGE'")
  }

  scope :by_draft_url, ->(draft_url) {
    coming_soon.where("project_integrations.data->>'draft_url' = ? ", draft_url)
  }

  private

  def can_activate_coming_soon
    return unless name == 'COMING_SOON_LANDING_PAGE'

    set_project_validations

    errors.merge!(project)
  end

  def set_project_validations
    project.validates_length_of :name, maximum: Project::NAME_MAXLENGTH
    project.validates_presence_of :headline
    project.validates_presence_of(:uploaded_image) if project.video_thumbnail.blank?
  end
end
