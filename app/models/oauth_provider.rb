class OauthProvider < ActiveRecord::Base
  # schema_associations was not working well here, 
  # maybe because we need this model during the application initialization
  # Not a big deal since we have only one association
  has_many :authorizations 
end
