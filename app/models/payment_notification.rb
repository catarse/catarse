class PaymentNotification < ActiveRecord::Base
  schema_associations
  serialize :extra_data, JSON
end
