class AddLastTokenToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :last_token, :text
  end
end
