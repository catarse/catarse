class ShippingFee < ActiveRecord::Base
  include I18n::Alchemy
  belongs_to :reward
end
