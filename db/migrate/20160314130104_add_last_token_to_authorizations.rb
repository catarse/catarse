class AddLastTokenToAuthorizations < ActiveRecord::Migration[4.2]
  def change
    add_column :authorizations, :last_token, :text
  end
end
