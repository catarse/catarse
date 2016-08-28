class RemoveNotNullFromSendgridEvents < ActiveRecord::Migration
  def change
    change_column_null :sendgrid_events, :notification_user, true
  end
end
