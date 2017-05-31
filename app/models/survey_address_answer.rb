class SurveyAddressAnswer < ActiveRecord::Base
  belongs_to :address
  belongs_to :contribution

end
