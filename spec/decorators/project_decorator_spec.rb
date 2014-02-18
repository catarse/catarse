require 'spec_helper'

describe ProjectDecorator do
  let(:project){ create(:project, about: 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here') }

  describe "#time_to_go" do
    let(:project){ build(:project) }
    let(:expires_at){ Time.zone.parse("23:00:00") }
    subject{ project.time_to_go }
    before do
      I18n.locale = :pt
      project.stub(:expires_at).and_return(expires_at)
    end

    context "when there is more than 1 day to go" do
      let(:expires_at){ Time.zone.now + 2.days }
      it{ should == {time:2, unit:"dias"} }
    end

    context "when there is less than 1 day to go" do
      let(:expires_at){ Time.zone.now + 13.hours }
      it{ should == {time:13, unit:"horas"} }
    end

    context "when there is less than 1 hour to go" do
      let(:expires_at){ Time.zone.now + 59.minutes }
      it{ should == {time:59, unit:"minutos"} }
    end
  end

  describe "#progress" do
    subject{ project.progress }
    let(:pledged){ 0.0 }
    let(:goal){ 0.0 }
    before do
        project.stub(:pledged).and_return(pledged)
        project.stub(:goal).and_return(goal)
    end

    context "when goal == pledged > 0" do
      let(:goal){ 10.0 }
      let(:pledged){ 10.0 }
      it{ should == 100 }
    end

    context "when goal is > 0 and pledged is 0.0" do
      let(:goal){ 10.0 }
      it{ should == 0 }
    end

    context "when goal is 0.0 and pledged > 0.0" do
      let(:pledged){ 10.0 }
      it{ should == 0 }
    end

    context "when goal is 0.0 and pledged is 0.0" do
      it{ should == 0 }
    end
  end

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

  describe "#status_flag" do
    let(:project) { create(:project) }

    context "When the project is successful" do
      it "should return a successful image flag when the project is successful" do
        project.stub(:successful?).and_return(true)

        expect(project.status_flag).to eq("<div class=\"status_flag\"><img alt=\"Successful.#{I18n.locale}\" src=\"/assets/successful.#{I18n.locale}.png\" /></div>")
      end
    end

    context "When the project was not successful" do
      it "should return a not successful image flag when the project is not successful" do
        project.stub(:failed?).and_return(true)

        expect(project.status_flag).to eq("<div class=\"status_flag\"><img alt=\"Not successful.#{I18n.locale}\" src=\"/assets/not_successful.#{I18n.locale}.png\" /></div>")
      end
    end

    context "When the project is in waiting funds" do
      it "should return a waiting funds image flag when the project is waiting funds" do
        project.stub(:waiting_funds?).and_return(true)

        expect(project.status_flag).to eq("<div class=\"status_flag\"><img alt=\"Waiting confirmation.#{I18n.locale}\" src=\"/assets/waiting_confirmation.#{I18n.locale}.png\" /></div>")
      end
    end

  end
end

