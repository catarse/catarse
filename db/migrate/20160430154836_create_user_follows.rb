class CreateUserFollows < ActiveRecord::Migration
  def up
    create_table :user_follows do |t|
      t.references :user, index: true
      t.integer :follow_id, foreign_key: false, index: true

      t.timestamps
    end

    execute %Q{
CREATE UNIQUE INDEX user_follow_uidx ON public.user_follows(user_id, follow_id);
    }
  end

  def down
    drop_table :user_follows
  end
end
