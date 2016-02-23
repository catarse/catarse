class CreateProjectAccountErrors < ActiveRecord::Migration
  def change
    create_table :project_account_errors do |t|
      t.integer :project_account_id, null: false
      t.text :reason, null: false
      t.boolean :solved, default: false
      t.datetime :solved_at

      t.timestamps
    end
  end
end
