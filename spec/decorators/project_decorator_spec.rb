require 'spec_helper'

describe ProjectDecorator do
  let(:project){ create(:project, about: 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here') }

  describe "#display_expires_at" do
    subject{ project.display_expires_at }

    context "when online_date is nil" do
      let(:project){ create(:project, online_date: nil) }
      it{ should == '' }
    end

    context "when we have an online_date" do
      let(:project){ create(:project, online_date: Time.now) }
      before do
        I18n.should_receive(:l).with(project.expires_at.to_date)
      end
      it("should call I18n with date"){ subject }
    end
  end

  describe "#display_image" do
    subject{ project.display_image }

    context "when we have a video_url without thumbnail" do
      let(:project){ create(:project, uploaded_image: nil, video_thumbnail: nil) }
      it{ should == project.video.thumbnail_large }
    end

    context "when we have a video_thumbnail" do
      let(:project){ create(:project, video_thumbnail: File.open("#{Rails.root}/spec/fixtures/image.png")) }
      it{ should == project.video_thumbnail.project_thumb.url }
    end

    context "when we have an uploaded_image" do
      let(:project){ create(:project, uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png"), video_thumbnail: nil) }
      it{ should == project.uploaded_image.project_thumb.url }
    end
  end

  describe "#about_html" do
    subject{ project.about_html }
    it{ should == '<p>Foo Bar <a href="http://www.foo.bar" target="_blank">http://www.foo.bar</a> &lt;javascript&gt;xss()&lt;/javascript&gt;<a target="_blank" href="http://click.here">Click here</a></p>' }
  end

  describe "#display_progress" do
    subject{ project.display_progress }
    context "when progress is 0" do
      before{ project.stub(:progress).and_return(0) }
      it{ should == 0 }
    end
    context "when progress is between 0 and 8" do
      before{ project.stub(:progress).and_return(7) }
      it{ should == 8 }
    end
    context "when progress is between 8 and 100" do
      before{ project.stub(:progress).and_return(70) }
      it{ should == 70 }
    end
    context "when progress is above 100" do
      before{ project.stub(:progress).and_return(101) }
      it{ should == 100 }
    end
  end

  describe "#display_status" do
    subject{ project.display_status }
    context "when online and reached goal" do
      before do
        project.stub(:state).and_return('online')
        project.stub(:reached_goal?).and_return(true)
      end
      it{ should == 'reached_goal' }
    end
    context "when online and have not reached goal yet" do
      before do
        project.stub(:state).and_return('online')
        project.stub(:reached_goal?).and_return(false)
      end
      it{ should == 'not_reached_goal' }
    end
    context "when failed" do
      before do
        project.stub(:state).and_return('failed')
      end
      it{ should == 'failed' }
    end
    context "when successful" do
      before do
        project.stub(:state).and_return('successful')
      end
      it{ should == 'successful' }
    end
    context "when waiting funds" do
      before do
        project.stub(:state).and_return('waiting_funds')
      end
      it{ should == 'waiting_funds' }
    end
  end

  describe '#display_video_embed_url' do
    subject{ project.display_video_embed_url }

    context 'source has a Vimeo video' do
      let(:project) { create(:project, video_url: 'http://vimeo.com/17298435') }

      it { should == 'http://player.vimeo.com/video/17298435?title=0&byline=0&portrait=0&autoplay=0' }
    end

    # In catarse.me we accept only vimeo videos, but feel free to uncomment this in your fork
    # and adjust the project model accordingly :D
    #context 'source has an Youtube video' do
      #let(:project) { create(:project, video_url: "http://www.youtube.com/watch?v=Brw7bzU_t4c") }

      #it { should == 'http://www.youtube.com/embed/Brw7bzU_t4c?title=0&byline=0&portrait=0&autoplay=0' }
    #end

    context 'source does not have a video' do
      let(:project) { create(:project, video_url: "") }

      it { should be_nil }
    end
  end


  describe "#successful_flag" do
    let(:project) { create(:project) }

    context "When the project is successful" do
      it "should return a successful image flag when the project is successful" do
        project.stub(:successful?).and_return(true)

        expect(project.successful_flag).to eq('<div class="successful_flag"><img alt="Successful" src="/assets/channels/successful.png" /></div>')
      end
    end

    context "When the project was not successful" do
      it "should not return an image, but nil" do
        expect(project.successful_flag).to eq(nil)
      end
    end
  end
end

