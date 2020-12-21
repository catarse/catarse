class AddColumnToReward < ActiveRecord::Migration[4.2]
  def change
    # this migrations should be before the thumbnail from users at localdev
    #add_column :rewards, :uploaded_image, :string
  end
end
