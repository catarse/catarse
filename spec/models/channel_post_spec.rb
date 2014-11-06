require 'rails_helper'

RSpec.describe ChannelPost, type: :model do
  describe "validations" do
    it{ is_expected.to validate_presence_of :user_id }
    it{ is_expected.to validate_presence_of :channel_id }
    it{ is_expected.to validate_presence_of :body }
    it{ is_expected.to validate_presence_of :body_html }
  end

  describe '.visible' do
    subject { ChannelPost.visible }

    before do
      5.times { create(:channel_post, visible: true) }
      3.times { create(:channel_post, visible: false) }
    end

    it { is_expected.to have(5).itens }
  end

  describe "#email_body_html" do
    subject{ create(:channel_post, body: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_body_html }
    it{ is_expected.to eq("<p>this is a comment\n<a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a>\n<img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>\n") }
  end

end
