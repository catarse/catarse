class DonatedContribution < ActiveRecord::Base
  belongs_to :contribution
  validates_uniqueness_of :contribution
end

