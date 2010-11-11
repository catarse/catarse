require 'spec_helper'

describe User do
  it "should validate presence of name" do
    u = User.new :email => "foo@bar.com", :password

  end
end

