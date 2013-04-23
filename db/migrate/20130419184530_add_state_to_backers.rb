class AddStateToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :state, :string
  end
end
