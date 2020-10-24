class AddSendgridRecipientIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sendgrid_recipient_id, :string, foreign_key: false
  end
end
