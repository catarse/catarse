# frozen_string_literal: true

class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :contributions
  has_many :rewards
  has_many :project_transitions
  belongs_to :city
  has_one :account, class_name: "ProjectAccount", inverse_of: :project

  def pluck_from_database attribute
    Project.where(id: self.id).pluck("projects.#{attribute}").first
  end

  %w(
    draft rejected online successful waiting_funds
    deleted in_analysis approved failed
  ).each do |st|
    define_method "#{st}_at" do
      pluck_from_database("#{st}_at")
    end
  end
end
