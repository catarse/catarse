class AddTimestampToAntifraudAnalyses < ActiveRecord::Migration[4.2]
  def change
    change_table :antifraud_analyses do |t|
      t.timestamps
    end
  end
end
