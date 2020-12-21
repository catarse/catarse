class SetDefaultRecipient < ActiveRecord::Migration[4.2]
  def change
    execute "alter table project_posts alter COLUMN recipients set default 'backers';"
  end
end
