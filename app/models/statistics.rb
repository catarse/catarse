class Statistics < ActiveRecord::Base
  default_scope { order('total_users DESC') }
  include Shared::MaterializedView
end
