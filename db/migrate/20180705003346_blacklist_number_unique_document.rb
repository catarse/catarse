class BlacklistNumberUniqueDocument < ActiveRecord::Migration[4.2]
  def change
    add_index :blacklist_documents, :number, unique: true
  end
end
