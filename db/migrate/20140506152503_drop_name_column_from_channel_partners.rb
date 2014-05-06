class DropNameColumnFromChannelPartners < ActiveRecord::Migration
  def change
    remove_column :channel_partners, :name
  end
end
