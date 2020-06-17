class CreateRewardMetricStorages < ActiveRecord::Migration
  def change
    create_table :reward_metric_storages do |t|
      t.references :reward, index: true, foreign_key: true
      t.jsonb :data, null: false, default: {}
      t.datetime :refreshed_at, null: false

      t.timestamps null: false
    end

    add_index :reward_metric_storages, :reward_id, unique: true, name: 'uidx_reward_id_metric_storages'
  end
end
