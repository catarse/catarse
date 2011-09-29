require 'spec_helper'

describe PaymentLog do
  it { should belong_to(:backer) }
end



# == Schema Information
#
# Table name: payment_logs
#
#  id             :integer         not null, primary key
#  backer_id      :integer
#  status         :integer
#  amount         :float
#  payment_status :integer
#  moip_id        :integer
#  payment_method :integer
#  consumer_email :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  payment_type   :string(255)
#

