require 'spec_helper'

describe ChannelDecorator do
  let(:channel){ build(:channel, facebook: 'http://www.facebook.com/foobar', twitter: 'http://twitter.com/foobar', website: 'http://foobar.com') }

  describe "#display_facebook" do
    subject{ channel.display_facebook }
    it{ should eq('foobar') }
  end

  describe "#display_twitter" do
    subject{ channel.display_twitter }
    it{ should eq('@foobar') }
  end

  describe "#display_website" do
    subject{ channel.display_website }
    it{ should eq('foobar.com') }
  end
end

