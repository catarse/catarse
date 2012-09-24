require 'spec_helper'

describe Notification do
  it{ should belong_to :user }
  it{ should belong_to :project }
  it{ should belong_to :notification_type }
  it{ should belong_to :backer }

  let(:backer){ Factory(:backer) }

  describe ".notify_backer" do
    before do
      Factory(:notification_type, :name => 'confirm_backer')
    end

    context "when NotificationType with the provided name does not exist" do
      subject{ Notification.notify_backer(backer, :test) }
      it("should raise error"){ lambda{ subject }.should raise_error("There is no NotificationType with name test") }
    end

    context "when NotificationType with the provided name exists" do
      subject{ Notification.notify_backer(backer, :confirm_backer) }
      its(:backer){ should == backer }
    end
  end
end
