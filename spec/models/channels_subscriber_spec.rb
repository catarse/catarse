require 'spec_helper'

describe ChannelsSubscriber do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :channel }
  end
end
