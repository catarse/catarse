class CreateIndexOnContributionsCreatedAt < ActiveRecord::Migration[4.2]
  def change
    add_index :contributions, :created_at
  end
end
