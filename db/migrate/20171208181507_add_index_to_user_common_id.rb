class AddIndexToUserCommonId < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    execute %{
    CREATE UNIQUE INDEX CONCURRENTLY users_common_id_z_uidx ON users(common_id);
    }
    execute %{
    CREATE UNIQUE INDEX CONCURRENTLY rewards_common_id_z_uidx ON rewards(common_id);
    }
  end
end
