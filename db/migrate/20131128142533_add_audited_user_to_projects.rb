class AddAuditedUserToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :audited_user_name, :string
    add_column :projects, :audited_user_cpf, :string
    add_column :projects, :audited_user_moip_login, :string
    add_column :projects, :audited_user_phone_number, :string
  end
end
