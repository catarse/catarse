class AddProjectInstallments < ActiveRecord::Migration
  def up
    add_column :projects, :total_installments, :integer, default: 3, null: false
  end

  def down
    remove_column :projects, :total_installments
  end
end
