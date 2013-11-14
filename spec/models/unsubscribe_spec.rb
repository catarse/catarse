require 'spec_helper'

describe Unsubscribe do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
  end

  describe ".updates_unsubscribe" do
    subject{ Unsubscribe.updates_unsubscribe(1618) }
    it{ should_not be_persisted }
    its(:class){ should == Unsubscribe }
    its(:project_id){ should == 1618 }

    context "when project_id is nil" do
      subject{ Unsubscribe.updates_unsubscribe(nil) }
      its(:class){ should == Unsubscribe }
      its(:project_id){ should be_nil }
    end
  end
end
