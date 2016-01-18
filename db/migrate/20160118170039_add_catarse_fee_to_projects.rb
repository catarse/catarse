class AddCatarseFeeToProjects < ActiveRecord::Migration
  def change
    execute "ALTER TABLE projects DISABLE TRIGGER sent_validation;"
    execute "UPDATE projects SET service_fee = 0.13;"
    execute "ALTER TABLE projects ENABLE TRIGGER sent_validation;"
  end
end
