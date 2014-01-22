class ContributionReport < ActiveRecord::Base
  attr_accessible :title, :body
  acts_as_copy_target
end
