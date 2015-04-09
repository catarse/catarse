class MergeProjectAccountsFields < ActiveRecord::Migration
  def change
    execute <<-SQL
      update project_accounts set owner_name = full_name, owner_document = cpf where cpf IS NOT NULL AND full_name IS NOT NULL;
    SQL
    remove_column :project_accounts, :full_name
    remove_column :project_accounts, :cpf
  end
end
