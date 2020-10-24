class CreateMoments < ActiveRecord::Migration[4.2]
  def up
    create_table :moments do |t|
      t.timestamps
    end

    execute %{
    ALTER TABLE public.moments
        ADD COLUMN data jsonb DEFAULT '{}',
        ALTER COLUMN created_at SET DEFAULT now(),
        ALTER COLUMN updated_at SET DEFAULT now();
    }
  end

  def down
    drop_table :moments
  end
end
