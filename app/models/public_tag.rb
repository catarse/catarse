# frozen_string_literal: true

class PublicTag < ApplicationRecord
  self.table_name = 'public.public_tags'

  has_many :taggings
  has_many :projects, through: :taggings

  validates_uniqueness_of :slug
end
