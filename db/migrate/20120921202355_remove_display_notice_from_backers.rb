class RemoveDisplayNoticeFromBackers < ActiveRecord::Migration
  def up
    remove_column :backers, :display_notice
  end

  def down
    add_column :backers, :display_notice, :boolean
  end
end
