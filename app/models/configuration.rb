class Configuration < ActiveRecord::Base
  validates_presence_of :name
end

# == Schema Information
#
# Table name: configurations
#
#  id         :integer         not null, primary key
#  name       :text            not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

