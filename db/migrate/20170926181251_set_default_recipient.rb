class SetDefaultRecipient < ActiveRecord::Migration
  def change
    execute "alter table project_posts alter COLUMN recipients set default 'backers';"
  end
end
