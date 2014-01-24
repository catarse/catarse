class RenameBackerToContribution < ActiveRecord::Migration
  def change
    rename_table :backers, :contributions
  end
end
