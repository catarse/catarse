# frozen_string_literal: true

class PublicTag < ActiveRecord::Base
  has_many :taggings
  has_many :projects, through: :taggings

  validates_uniqueness_of :slug

  self.table_name = 'public.public_tags'
end
