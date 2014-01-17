require 'spec_helper'

describe Project::VideoHandler do
  let(:project) { create(:project) }

  describe "#download_video_thumbnail" do
    before do
      project.should_receive(:download_video_thumbnail).and_call_original
      project.should_receive(:open).and_return(File.open("#{Rails.root}/spec/fixtures/image.png"))

      project.download_video_thumbnail
    end

    it "should open the video_url and store it in video_thumbnail" do
      project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
    end
  end

  describe "#update_video_embed_url" do
    before do
      project.video_url = 'http://vimeo.com/49584778'
      project.video.should_receive(:embed_url).and_call_original
      project.update_video_embed_url
    end

    it "should store the new embed url" do
      project.video_embed_url.should == 'player.vimeo.com/video/49584778'
    end
  end
end
