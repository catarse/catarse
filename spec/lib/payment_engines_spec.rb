# encoding: utf-8

require 'spec_helper'

describe PaymentEngines do
  let(:contribution){ FactoryGirl.create(:contribution) }
  let(:paypal_engine) { double }
  let(:moip_engine) { double }

  before do
    PaymentEngines.clear
    paypal_engine.stub(:name).and_return('PayPal')
    paypal_engine.stub(:review_path).with(contribution).and_return("/#{contribution}")
    paypal_engine.stub(:locale).and_return('en')

    moip_engine.stub(:name).and_return('MoIP')
    moip_engine.stub(:review_path).with(contribution).and_return("/#{contribution}")
    moip_engine.stub(:locale).and_return('pt')
  end

  let(:engine){ paypal_engine }
  let(:engine_pt){ moip_engine }

  describe ".find_engine" do
    before do
      PaymentEngines.register engine
      PaymentEngines.register engine_pt
    end

    subject { PaymentEngines.find_engine('MoIP') }

    it { should == engine_pt }
  end

  describe ".register" do
    before{ PaymentEngines.register engine }
    subject{ PaymentEngines.engines }
    it{ should == [engine] }
  end

  describe ".clear" do
    before do
      PaymentEngines.register engine
      PaymentEngines.clear
    end
    subject{ PaymentEngines.engines }
    it{ should be_empty }
  end

  describe ".configuration" do
    subject{ PaymentEngines.configuration }
    it{ should == ::Configuration }
  end

  describe ".create_payment_notification" do
    subject{ PaymentEngines.create_payment_notification({ contribution_id: contribution.id, extra_data: { test: true } }) }
    it{ should == PaymentNotification.where(contribution_id: contribution.id).first }
  end

  describe ".find_payment" do
    subject{ PaymentEngines.find_payment({ id: contribution.id }) }
    it{ should == contribution }
  end

  describe ".engines" do
    subject{ PaymentEngines.engines }
    before do
      PaymentEngines.register engine
      PaymentEngines.register engine_pt
    end
    context "when locale is pt" do
      before do
        I18n.locale = :pt
      end
      it{ should == [engine_pt, engine] }
    end

    context "when locale is en" do
      before do
        I18n.locale = :en
      end
      it{ should == [engine, engine_pt] }
    end
  end
end
