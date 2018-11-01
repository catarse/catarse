# frozen_string_literal: true

class Country < ActiveRecord::Base
  include Shared::CommonWrapper
  after_save :index_on_common

  def common_index
    # @TODO send translations
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      name: name,
      name_en: name_en,
      created_at: created_at.try(:strftime, "%FT%T"),
      updated_at: updated_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_country(self) if common_wrapper
  end
end
