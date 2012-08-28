class PaymentNotification < ActiveRecord::Base
  serialize :extra_data, ActiveRecord::Coders::Hstore
end
