require 'spec_helper'

describe Unsubscribe do
  let(:notification_type){ FactoryGirl.create(:notification_type, name: 'updates') }

  before do
    notification_type
  end
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :notification_type }
    it{ should belong_to :project }
  end

  describe ".updates_unsubscribe" do
    subject{ Unsubscribe.updates_unsubscribe(1618) }
    it{ should_not be_persisted }
    its(:class){ should == Unsubscribe }
    its(:notification_type_id){ should == notification_type.id }
    its(:project_id){ should == 1618 }

    context "when project_id is nil" do
      subject{ Unsubscribe.updates_unsubscribe(nil) }
      its(:class){ should == Unsubscribe }
      its(:notification_type_id){ should == notification_type.id }
      its(:project_id){ should be_nil }
    end
  end
end
