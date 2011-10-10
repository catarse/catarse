class OauthProvider < ActiveRecord::Base
end

# == Schema Information
#
# Table name: oauth_providers
#
#  id         :integer         not null, primary key
#  name       :text            not null
#  key        :text            not null
#  secret     :text            not null
#  scope      :text
#  order      :integer
#  created_at :datetime
#  updated_at :datetime
#  strategy   :text
#  path       :text
#

