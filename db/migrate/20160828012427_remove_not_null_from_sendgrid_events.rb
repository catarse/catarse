class RemoveNotNullFromSendgridEvents < ActiveRecord::Migration[4.2]
  def change
    change_column_null :sendgrid_events, :notification_user, true
  end
end
