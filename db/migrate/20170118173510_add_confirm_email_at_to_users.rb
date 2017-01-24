class AddConfirmEmailAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmed_email_at, :datetime
  end
end
