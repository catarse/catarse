# frozen_string_literal: true

class ProjectError < ApplicationRecord
  belongs_to :project

  validates :error, :to_state, presence: true
end
