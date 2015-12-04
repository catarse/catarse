class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :projects, through: :taggings

  validates_uniqueness_of :slug
end
