# coding: utf-8
# frozen_string_literal: true

class Goal < ActiveRecord::Base
  include I18n::Alchemy
  belongs_to :project

  validates_presence_of :value, :description, :title
  validates_numericality_of :value, greater_than: 9, allow_blank: true

end
