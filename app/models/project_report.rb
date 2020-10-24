# coding: utf-8
# frozen_string_literal: true

class ProjectReport < ApplicationRecord
  has_notifications
  belongs_to :project
  validates_presence_of :project_id, :email, :reason
end
