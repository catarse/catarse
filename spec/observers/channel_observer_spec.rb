require 'spec_helper'

describe ChannelObserver do
  subject { build(:channel, video_url: 'http://www.youtube.com/watch?v=YWj8ws6jc0g') }

  describe '.after_save' do
    context "when video url is changed" do
      before do
        subject.should_receive(:update_video_embed_url)
      end

      it "should call update_video_embed_url" do
        subject.save
      end
    end

    context "when video url is not changed" do
      before do
        subject.stub(:video_url_changed?).and_return(false)
        subject.should_receive(:update_video_embed_url).never
      end

      it "should not call update_video_embed_url" do
        subject.save
      end
    end
  end
end
