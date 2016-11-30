class AddSendgridRecipientIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sendgrid_recipient_id, :string, foreign_key: false
  end
end
