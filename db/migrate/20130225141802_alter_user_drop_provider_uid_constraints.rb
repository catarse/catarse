class AlterUserDropProviderUidConstraints < ActiveRecord::Migration[4.2]
  def up
    execute "
    ALTER TABLE users ALTER provider DROP NOT NULL;
    ALTER TABLE users ALTER uid DROP NOT NULL;
    "
  end

  def down
    execute "
    ALTER TABLE users ALTER provider SET NOT NULL;
    ALTER TABLE users ALTER uid SET NOT NULL;
    "
  end
end
