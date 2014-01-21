class RenameBackerAssociations < ActiveRecord::Migration
  def change
    rename_column :notifications, :backer_id, :contribution_id
    rename_column :payment_notifications, :backer_id, :contribution_id
    rename_column :rewards, :maximum_backers, :maximum_contributions
    rename_column :projects, :first_backers, :first_contributions
  end
end
