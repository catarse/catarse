class SurveyAddressAnswer < ActiveRecord::Base
  belongs_to :address
  belongs_to :contribution

  accepts_nested_attributes_for :address
end
