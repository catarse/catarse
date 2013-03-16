require 'spec_helper'

describe ProjectDecorator do
  let(:project){ FactoryGirl.create(:project, :about => 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here') }

  describe "#display_image" do
    subject{ project.display_image }

    context "when we have a video_url without thumbnail" do
      let(:project){ FactoryGirl.create(:project, :uploaded_image => nil, :image_url => nil, :video_thumbnail => nil) }
      it{ should == project.video.thumbnail_large } 
    end

    context "when we have a video_thumbnail" do
      let(:project){ FactoryGirl.create(:project, :image_url => nil, :video_thumbnail => File.open("#{Rails.root}/spec/fixtures/image.png")) }
      it{ should == project.video_thumbnail.url } 
    end

    context "when we have a thumbnail and an image_url" do
      let(:project){ FactoryGirl.create(:project, :image_url => 'http://test.com/image', :video_thumbnail => File.open("#{Rails.root}/spec/fixtures/image.png")) }
      it{ should == 'http://test.com/image' } 
    end
  end

  describe "#about_html" do
    subject{ project.about_html }
    it{ should == '<p>Foo Bar <a href="http://www.foo.bar" target="_blank">http://www.foo.bar</a> &lt;javascript&gt;xss()&lt;/javascript&gt;<a target="_blank" href="http://click.here">Click here</a></p>' }
  end

  describe "#display_progress" do
    subject{ project.display_progress }
    context "when progress is 0" do
      before{ project.stubs(:progress).returns(0) }
      it{ should == 0 }
    end
    context "when progress is between 0 and 8" do
      before{ project.stubs(:progress).returns(7) }
      it{ should == 8 }
    end
    context "when progress is between 8 and 100" do
      before{ project.stubs(:progress).returns(70) }
      it{ should == 70 }
    end
    context "when progress is above 100" do
      before{ project.stubs(:progress).returns(101) }
      it{ should == 100 }
    end
  end

  describe "#display_status" do
    subject{ project.display_status }
    context "when online and reached goal" do
      before do
        project.stubs(:state).returns('online')
        project.stubs(:reached_goal?).returns(true)
      end
      it{ should == 'reached_goal' }
    end
    context "when online and have not reached goal yet" do
      before do
        project.stubs(:state).returns('online')
        project.stubs(:reached_goal?).returns(false)
      end
      it{ should == 'not_reached_goal' }
    end
    context "when failed" do
      before do
        project.stubs(:state).returns('failed')
      end
      it{ should == 'failed' }
    end
    context "when successful" do
      before do
        project.stubs(:state).returns('successful')
      end
      it{ should == 'successful' }
    end
    context "when waiting funds" do
      before do
        project.stubs(:state).returns('waiting_funds')
      end
      it{ should == 'waiting_funds' }
    end
  end

  describe '#video_embed_url' do
    subject{ project.video_embed_url }

    context 'source has a Vimeo video' do
      before { project.video_url = 'http://vimeo.com/17298435' }

      it { should == 'http://player.vimeo.com/video/17298435?title=0&amp;byline=0&amp;portrait=0&amp;autoplay=0' }
    end

    context 'source has an Youtube video' do
      before { project.video_url = "http://www.youtube.com/watch?v=Brw7bzU_t4c" }

      it { should == 'http://www.youtube.com/embed/Brw7bzU_t4c' }
    end

    context 'source does not have a video' do
      before { project.video_url = '' }

      it { should be_nil }
    end
  end
end

