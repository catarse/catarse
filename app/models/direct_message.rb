# coding: utf-8
# frozen_string_literal: true

class DirectMessage < ActiveRecord::Base
  has_notifications
  belongs_to :user
  belongs_to :project
  validates_presence_of :user_id, :from_email, :content
end
