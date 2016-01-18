class AddCatarseFeeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :catarse_fee, :numeric
    execute "ALTER TABLE projects DISABLE TRIGGER sent_validation;"
    execute "ALTER TABLE ONLY projects ALTER COLUMN catarse_fee SET DEFAULT 0.13;"
    execute "UPDATE projects SET catarse_fee = 0.13;"
    execute "ALTER TABLE projects ENABLE TRIGGER sent_validation;"
  end
end
