class UserTotal < ActiveRecord::Base
  include Shared::MaterializedView
  self.primary_key = :id
end
