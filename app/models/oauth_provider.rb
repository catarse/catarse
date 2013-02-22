class OauthProvider < ActiveRecord::Base
  schema_associations rescue puts "problem loading schema_associations, maybe it has not been defined yet"
end
