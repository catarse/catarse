require 'spec_helper'

describe ChannelPost do
  describe "validations" do
    it{ should validate_presence_of :user_id }
    it{ should validate_presence_of :channel_id }
    it{ should validate_presence_of :body }
    it{ should validate_presence_of :body_html }
  end
end
