# encoding: utf-8

require 'spec_helper'

describe PaymentEngines do
  let(:engine){ {name: 'test', review_path: ->(backer){ "/#{backer}" }, locale: 'en'} }
  let(:engine_pt){ {name: 'test pt', review_path: ->(backer){ "/#{backer}" }, locale: 'pt'} }
  let(:backer){ FactoryGirl.create(:backer) }
  before{ PaymentEngines.clear }

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

  describe ".refund!" do
    let(:backer){ FactoryGirl.create(:backer, state: 'confirmed') }
    before do
      PaymentEngines.refund!({ id: backer.id })
    end

    it "should change backer status to refunded" do
      backer.reload.refunded?.should be_true
    end
  end

  describe ".confirm!" do
    before do
      PaymentEngines.confirm!({ id: backer.id })
    end

    it "should change backer status to confirmed" do
      backer.reload.confirmed?.should be_true
    end
  end

  describe ".cancel!" do
    before do
      PaymentEngines.cancel!({ id: backer.id })
    end

    it "should change backer status to canceled" do
      backer.reload.canceled?.should be_true
    end
  end

  describe ".create_payment_notification" do
    let(:data){ { 'test' => true } }
    before do
      PaymentEngines.create_payment_notification({ id: backer.id }, data)
    end

    it "should create payment notification with data" do
      backer.reload.payment_notifications.first.extra_data.should == data
    end
  end

  describe ".update_payment_data" do
    before do
      PaymentEngines.update_payment_data({ id: backer.id }, {
        payment_id: 'payment id',
        payment_choice: 'payment choice',
        payment_service_fee: 99.6
      })
    end

    it "should update payment id" do
      backer.reload.payment_id.should == 'payment id'
    end

    it "should update payment choice" do
      backer.reload.payment_choice.should == 'payment choice'
    end

    it "should update payment service fee" do
      backer.reload.payment_service_fee.should == 99.6
    end
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
