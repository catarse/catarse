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

  describe "#email_body_html" do
    subject{ create(:channel_post, body: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_body_html }
    it{ should == "<p>this is a comment<br />\n<a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a><br />\n<img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>" }
  end

  describe "#post_number" do
    let(:channel){ create(:channel) }
    let(:post){ create(:channel_post, channel: channel) }

    subject{ post.post_number}

    before do
      create(:channel_post, channel: channel)
      post
      create(:channel_post, channel: channel)
    end
    it{ should == 2 }
  end

end
