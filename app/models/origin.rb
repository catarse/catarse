class Origin < ActiveRecord::Base
  has_many :projects
  has_many :contributions
end
