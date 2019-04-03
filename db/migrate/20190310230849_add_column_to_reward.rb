class AddColumnToReward < ActiveRecord::Migration
  def change
    # this migrations should be before the thumbnail from users at localdev
    #add_column :rewards, :uploaded_image, :string
  end
end
