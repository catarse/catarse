# coding: utf-8
# frozen_string_literal: true

class DirectMessage < ActiveRecord::Base
  has_notifications
  belongs_to :user
  belongs_to :project
  validates_presence_of :user_id, :from_email, :content

  after_save :index_on_common

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      project_id: project.common_id,
      current_ip: project.user.current_sign_in_ip,
      user_id: user_id,
      to_user_id: to_user_id,
      from_email: from_email,
      from_name: from_name,
      content: content,
      data: data,
      created_at: created_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def common_wrapper_key
    CatarseSettings[:common_proxy_api_key]
  end

  def index_on_common
    common_wrapper.index_direct_message(self) if common_wrapper
  end
end
