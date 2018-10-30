# frozen_string_literal: true

class State < ActiveRecord::Base
  include Shared::CommonWrapper
  validates_presence_of :name, :acronym
  validates_uniqueness_of :name, :acronym

  has_many :cities
  after_save :index_on_common

  def self.array
    @array ||= order(:name).pluck(:name, :acronym).push(['Outro / Other', 'outro / other'])
  end

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      country_id: country.common_id,
      name: name,
      created_at: created_at.try(:strftime, "%FT%T"),
      updated_at: updated_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_state(self) if common_wrapper
  end
end
