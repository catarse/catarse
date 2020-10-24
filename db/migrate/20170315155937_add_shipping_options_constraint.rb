class AddShippingOptionsConstraint < ActiveRecord::Migration[4.2]
  def change
    execute "ALTER TABLE rewards ADD CONSTRAINT check_shipping_types CHECK (shipping_options IN('free', 'national', 'international', 'presential'));"
  end
end
