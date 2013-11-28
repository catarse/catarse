class AddAuditedUserToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :audited_user_name, :text
    add_column :projects, :audited_user_cpf, :text
    add_column :projects, :audited_user_moip_login, :text
    add_column :projects, :audited_user_phone_number, :text
  end
end
