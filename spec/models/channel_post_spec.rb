require 'spec_helper'

describe ChannelPost do
  describe "validations" do
    it{ should validate_presence_of :user_id }
    it{ should validate_presence_of :channel_id }
    it{ should validate_presence_of :body }
    it{ should validate_presence_of :body_html }
  end

  describe '.visible' do
    subject { ChannelPost.visible }

    before do
      5.times { create(:channel_post, visible: true) }
      3.times { create(:channel_post, visible: false) }
    end

    it { should have(5).itens }
  end
end
