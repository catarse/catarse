class AddConfirmEmailAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :confirmed_email_at, :datetime
  end
end
