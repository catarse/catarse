# coding: utf-8
# frozen_string_literal: true

class Goal < ActiveRecord::Base
  include I18n::Alchemy
  include Shared::CommonWrapper
  belongs_to :project

  validates_presence_of :value, :description, :title
  validates_numericality_of :value, greater_than: 9, allow_blank: true
  after_save :index_on_common

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      project_id: project.common_id,
      current_ip: project.user.current_sign_in_ip,
      value: value,
      title: title,
      description: description,
      created_at: created_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_goal(self) if common_wrapper
  end

end
