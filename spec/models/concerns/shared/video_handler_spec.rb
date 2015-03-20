require 'rails_helper'

RSpec.describe Shared::VideoHandler, type: :model do
  let(:project) { create(:project) }
  subject { project }

  describe '.validations' do
    it{ is_expected.to allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.not_to allow_value('http://www.foo.bar').for(:video_url) }
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

      it { is_expected.to eq('//player.vimeo.com/video/17298435?title=0&byline=0&portrait=0&autoplay=0') }
    end

    context 'source has an Youtube video' do
      let(:project) { create(:project, video_url: "http://www.youtube.com/watch?v=Brw7bzU_t4c") }

      before do
        project.reload
      end

      it { is_expected.to eq('//www.youtube.com/embed/Brw7bzU_t4c?title=0&byline=0&portrait=0&autoplay=0') }
    end

    context 'source does not have a video' do
      before do
        CatarseSettings[:minimum_goal_for_video] = 5000
      end
      let(:project) { create(:project, video_url: "", goal: 3000) }

      it { is_expected.to be_nil }
    end
  end



  describe "#update_video_embed_url" do
    let(:project) { create(:project, state: 'online') }
    before do
      project.video_url = "http://vimeo.com/17298435"
      project.budget = nil
    end
    subject{ project.update_video_embed_url }
    it{ is_expected.to eq true }
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
        expect(VideoInfo).to receive(:get).once.and_return(video_obj)
        5.times { project.video }
      end
    end
  end
end
