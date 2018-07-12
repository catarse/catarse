class BlacklistNumberUniqueDocument < ActiveRecord::Migration
  def change
    add_index :blacklist_documents, :number, unique: true
  end
end
