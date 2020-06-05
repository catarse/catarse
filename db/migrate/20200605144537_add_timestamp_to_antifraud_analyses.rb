class AddTimestampToAntifraudAnalyses < ActiveRecord::Migration
  def change
    change_table :antifraud_analyses do |t|
      t.timestamps
    end
  end
end
