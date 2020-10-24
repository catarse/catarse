class AddStateInscriptionToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :state_inscription, :string
  end
end
