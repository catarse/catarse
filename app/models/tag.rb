class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :projects, through: :taggings

end
