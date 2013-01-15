require 'spec_helper'

describe ProjectDecorator do
  let(:project){ Factory(:project, :about => 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here') }

  describe "#display_image" do
    subject{ project.display_image }

    context "when we have a video_url without thumbnail" do
      let(:project){ Factory(:project, :uploaded_image => nil, :image_url => nil, :video_thumbnail => nil) }
      it{ should == project.vimeo.thumbnail } 
    end

    context "when we have a video_thumbnail" do
      let(:project){ Factory(:project, :image_url => nil, :video_thumbnail => File.open("#{Rails.root}/spec/fixtures/image.png")) }
      it{ should == project.video_thumbnail.url } 
    end

    context "when we have a thumbnail and an image_url" do
      let(:project){ Factory(:project, :image_url => 'http://test.com/image', :video_thumbnail => File.open("#{Rails.root}/spec/fixtures/image.png")) }
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
    context "when successful and expired" do
      before do
        project.stubs(:successful?).returns(true)
        project.stubs(:expired?).returns(true)
      end
      it{ should == 'successful' }
    end

    context "when successful and in_time" do
      before do
        project.stubs(:successful?).returns(true)
        project.stubs(:in_time?).returns(true)
      end
      it{ should == 'in_time' }
    end

    context "when expired" do
      before{ project.stubs(:expired?).returns(true) }
      it{ should == 'expired' }
    end

    context "when waiting confirmation" do
      before{ project.stubs(:waiting_confirmation?).returns(true) }
      it{ should == 'waiting_confirmation' }
    end

    context "when in_time" do
      before{ project.stubs(:in_time?).returns(true) }
      it{ should == 'in_time' }
    end
  end

end

