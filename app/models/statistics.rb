class Statistics < ActiveRecord::Base
  default_scope { order('total_users DESC') }
  def self.refresh_view
    connection.execute('REFRESH MATERIALIZED VIEW statistics')
  end
end
