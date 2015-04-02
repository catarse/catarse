class AddSchema1ToSearchPath < ActiveRecord::Migration
  def up
    current_database = execute("SELECT current_database();")[0]["current_database"]
    execute %{ALTER DATABASE #{current_database} SET search_path TO "$user", public, "1";}
  end

  def down
  end
end
