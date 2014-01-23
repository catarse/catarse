# encoding: utf-8

require 'spec_helper'

describe PaymentEngines do
  let(:engine){ {name: 'test', review_path: ->(contribution){ "/#{contribution}" }, locale: 'en'} }
  let(:engine_pt){ {name: 'test pt', review_path: ->(contribution){ "/#{contribution}" }, locale: 'pt'} }
  let(:contribution){ FactoryGirl.create(:contribution) }
  before{ PaymentEngines.clear }

  describe ".find_engine" do
    before do
      PaymentEngines.register engine
      PaymentEngines.register engine_pt
    end

    subject { PaymentEngines.find_engine('test pt') }

    it { should == engine_pt}
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
