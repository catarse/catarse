class AdjustsOnMailMarketingLists < ActiveRecord::Migration
  def change
    add_column :mail_marketing_lists, :disabled_at, :datetime
    add_column :mail_marketing_lists, :provider_data, :jsonb
  end
end
