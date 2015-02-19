class CreateIndexOnContributionsCreatedAt < ActiveRecord::Migration
  def change
    add_index :contributions, :created_at
  end
end
