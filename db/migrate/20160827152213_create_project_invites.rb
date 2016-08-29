class CreateProjectInvites < ActiveRecord::Migration
  def change
    create_table :project_invites do |t|
      t.integer :project_id, null: false
      t.text :user_email, null: false

      t.timestamps
    end

    add_index :project_invites, [:user_email, :project_id], unique: true
  end
end
