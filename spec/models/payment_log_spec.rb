require 'spec_helper'

describe PaymentLog do
  it { should belong_to(:backer) }
end
