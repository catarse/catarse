class Authorization < ActiveRecord::Base
  attr_accessible :oauth_provider, :oauth_provider_id, :uid, :user_id
  schema_associations
  validates_presence_of :oauth_provider, :user, :uid

end
