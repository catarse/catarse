class MigrateShippingOptions < ActiveRecord::Migration[4.2]
  def change
    execute "update rewards set shipping_options = 'free';"
  end
end
