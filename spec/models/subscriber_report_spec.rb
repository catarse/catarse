require 'spec_helper'

describe SubscriberReport do
  let(:subscriber){ SubscriberReport.first }
  before(:all) do
    Configuration[:email_contact] = 'foo@bar.com'
    Configuration[:company_name] = 'Foo Bar Company'
    @channel = create(:channel) 
    @user = create(:user, subscriptions: [ @channel ])
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe "Associations" do
    it{ should belong_to :channel }
  end

  describe ".count" do
    subject{ SubscriberReport.count }
    it{ should eq 1 }
  end

  describe "#id" do
    subject{ subscriber.id }
    it{ should eq @user.id }
  end

  describe "#channel_id" do
    subject{ subscriber.channel_id }
    it{ should eq @channel.id }
  end

  describe "#name" do
    subject{ subscriber.name }
    it{ should eq @user.name }
  end

  describe "#email" do
    subject{ subscriber.email }
    it{ should eq @user.email }
  end
end
