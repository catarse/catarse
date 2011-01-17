require "spec_helper"

describe MoipMailer do
  it "should send payment received email" do
    backer = Factory(:backer)
    parameters = {'testing mailer' => 'ok'}
    email = MoipMailer.payment_received_email(backer, parameters).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /confirmed: true/
    email.encoded.should =~ /value: 10\.0/
    email.encoded.should =~ /testing mailer: ok/
  end

  it "should send payment received email with nil value in backer" do
    backer = nil
    parameters = {'testing mailer' => 'ok'}
    email = MoipMailer.payment_received_email(backer, parameters).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /testing mailer: ok/
  end

  it "should send error in payment email" do
    backer = Factory(:backer)
    parameters = {'testing mailer' => 'ok'}
    email = MoipMailer.error_in_payment_email(backer, parameters, Exception.new("test exception")).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.encoded.should =~ /value: 10\.0/
    email.encoded.should =~ /testing mailer: ok/
    email.encoded.should =~ /Exception/
    email.encoded.should =~ /Backtrace/
  end
end
