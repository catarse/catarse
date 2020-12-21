class DropNameColumnFromChannelPartners < ActiveRecord::Migration[4.2]
  def change
    remove_column :channel_partners, :name
  end
end
