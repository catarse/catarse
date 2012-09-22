require 'spec_helper'

describe Notification do
  it{ should belong_to :user }
  it{ should belong_to :project }
  it{ should belong_to :notification_type }
  it{ should belong_to :backer }

  let(:backer){ Factory(:backer) }

  describe ".notify_backer" do
    subject{ Notification.notify_backer(backer, Factory(:notification_type, :name => 'confirm_backer')) }
    its(:backer){ should == backer }
  end
end
