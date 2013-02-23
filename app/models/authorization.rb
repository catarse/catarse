class Authorization < ActiveRecord::Base
  attr_accessible :oauth_provider, :uid, :user_id
  schema_associations
end
