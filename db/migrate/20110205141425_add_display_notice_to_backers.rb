class AddDisplayNoticeToBackers < ActiveRecord::Migration
  def self.up
    add_column :backers, :display_notice, :boolean, :default => false
    execute("UPDATE backers SET display_notice = true WHERE confirmed = true")
  end

  def self.down
    remove_column :backers, :display_notice
  end
end

