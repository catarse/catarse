require 'rails_helper'

RSpec.describe ChannelObserver do
  subject { build(:channel, video_url: 'http://www.youtube.com/watch?v=YWj8ws6jc0g') }

  describe '.after_save' do
    context "when video url is changed" do
      before do
        expect(subject).to receive(:update_video_embed_url)
      end

      it "should call update_video_embed_url" do
        subject.save
      end
    end

    context "when video url is not changed" do
      before do
        allow(subject).to receive(:video_url_changed?).and_return(false)
        expect(subject).to receive(:update_video_embed_url).never
      end

      it "should not call update_video_embed_url" do
        subject.save
      end
    end
  end
end
