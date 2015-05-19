class RemoveOldContributionFields < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS temp.contribution_to_fix_details;"
    execute "DROP VIEW IF EXISTS user_feeds;"
    execute "DROP VIEW IF EXISTS contributions_by_periods;"
    remove_column :contributions, :confirmed_at
    remove_column :contributions, :key
    remove_column :contributions, :credits
    remove_column :contributions, :payment_method
    remove_column :contributions, :payment_token
    remove_column :contributions, :payment_id
    remove_column :contributions, :state
    remove_column :contributions, :waiting_confirmation_at
    remove_column :contributions, :canceled_at
    remove_column :contributions, :refunded_at
    remove_column :contributions, :requested_refund_at
    remove_column :contributions, :refunded_and_canceled_at
    remove_column :contributions, :invalid_payment_at
    remove_column :contributions, :slip_url
    remove_column :contributions, :installments
    remove_column :contributions, :address_country
    remove_column :contributions, :acquirer_name
    remove_column :contributions, :acquirer_tid
    remove_column :contributions, :installment_value
    remove_column :contributions, :card_brand
  end
end
