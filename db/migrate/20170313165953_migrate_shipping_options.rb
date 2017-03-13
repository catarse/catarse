class MigrateShippingOptions < ActiveRecord::Migration
  def change
    execute "update rewards set shipping_options = 'free';"
  end
end
