require 'spec_helper'

describe ChannelsSubscriber do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :channel }
  end

  describe "validations" do
    it{ should validate_presence_of :user_id }
    it{ should validate_presence_of :channel_id }
  end
end
