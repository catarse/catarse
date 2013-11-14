require 'spec_helper'

describe ProjectDownloader do
  let(:project) { create(:project) }

  subject { ProjectDownloader.new(project) }

  describe "#start!" do
    after(:each) do
      subject.start!
    end

    it "should call update_video_embed_url" do
      subject.should_receive(:update_video_embed_url).at_least(1)
    end

    it "should call download_video_thumbnail" do
      subject.should_receive(:download_video_thumbnail).at_least(1)
    end
  end


  describe "#download_video_thumbnail" do
    before do
      subject.should_receive(:download_video_thumbnail).and_call_original
      subject.should_receive(:open).and_return(File.open("#{Rails.root}/spec/fixtures/image.png"))
      subject.download_video_thumbnail
    end

    it "should open the video_url and store it in video_thumbnail" do
      project.save #NOTE: need to save the project to persist the image
      project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
    end
  end
end
