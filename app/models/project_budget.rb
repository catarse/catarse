# frozen_string_literal: true

class ProjectBudget < ApplicationRecord
  belongs_to :project

  validates :name, :value, presence: true
end
