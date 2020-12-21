class AddStateToBackers < ActiveRecord::Migration[4.2]
  def change
    add_column :backers, :state, :string
  end
end
