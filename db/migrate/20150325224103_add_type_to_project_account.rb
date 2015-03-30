class AddTypeToProjectAccount < ActiveRecord::Migration
  def change
    add_column :project_accounts, :person_type, :text

    execute <<-SQL
      update project_accounts set person_type  = 'Pessoa Física' where state_inscription  is null; 
      update project_accounts set person_type  = 'Pessoa Jurídica' where state_inscription  is not null; 
    SQL
  end
end
