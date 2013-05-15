class RemoveBooleanFieldsFromBackers < ActiveRecord::Migration
  def up
    execute "
    ALTER TABLE backers DROP IF EXISTS confirmed;
    ALTER TABLE backers DROP IF EXISTS requested_refund;
    ALTER TABLE backers DROP IF EXISTS refunded;"
  end

  def down
    add_column :backers, :confirmed, :boolean, default: false
    add_column :backers, :requested_refund, :boolean, default: false
    add_column :backers, :refunded, :boolean, default: false
  end
end
