require 'spec_helper'

describe Shared::VideoHandler do
  let(:project) { create(:project) }
  subject { project }

  describe '.validations' do
    it{ should allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('vimeo.com/12111').for(:video_url) }
    it{ should allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should_not allow_value('http://www.foo.bar').for(:video_url) }
  end

  describe '#display_video_embed_url' do
    before do
      Sidekiq::Testing.inline!
    end

    subject{ project.display_video_embed_url }

    context 'source has a Vimeo video' do
      let(:project) { create(:project, video_url: 'http://vimeo.com/17298435') }

      before do
        project.reload
      end

      it { should == '//player.vimeo.com/video/17298435?title=0&byline=0&portrait=0&autoplay=0' }
    end

    context 'source has an Youtube video' do
      let(:project) { create(:project, video_url: "http://www.youtube.com/watch?v=Brw7bzU_t4c") }

      before do
        project.reload
      end

      it { should == '//www.youtube.com/embed/Brw7bzU_t4c?title=0&byline=0&portrait=0&autoplay=0' }
    end

    context 'source does not have a video' do
      let(:project) { create(:project, video_url: "") }

      it { should be_nil }
    end
  end



  describe "#video" do
    subject { project }

    context "video_url is blank" do
      before { project.video_url = ''}

      its(:video){ should be_nil}
    end

    context 'video_url is defined' do
      before { project.video_url = "http://vimeo.com/17298435" }

      context 'video_url is a Vimeo url' do
        its(:video){ should be_an_instance_of(VideoInfo) }
      end

      context 'video_url is an YouTube url' do
        before { project.video_url = "http://www.youtube.com/watch?v=Brw7bzU_t4c" }

        its(:video){ should be_an_instance_of(VideoInfo) }
      end

      it 'caches the response object' do
        video_obj = VideoInfo.get(project.video_url)
        VideoInfo.should_receive(:get).once.and_return(video_obj)
        5.times { project.video }
      end
    end
  end
end
