class RenameBackerToContribution < ActiveRecord::Migration[4.2]
  def change
    rename_table :backers, :contributions
  end
end
