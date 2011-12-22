class AddCpfToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cpf, :text
  end

  def self.down
    remove_column :users, :cpf
  end
end
