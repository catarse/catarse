class AddTypeToProjectAccount < ActiveRecord::Migration
  def change
    add_column :project_accounts, :person_type, :text
  end
end
