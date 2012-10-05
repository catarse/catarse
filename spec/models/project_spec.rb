# coding: utf-8
require 'spec_helper'

describe Project do
  before{ Notification.stubs(:create_notification) }

  describe "associations" do
    it{ should have_many :projects_curated_pages }
    it{ should have_many :curated_pages }
    it{ should have_many :backers }
    it{ should have_one  :project_total }
    it{ should have_many :rewards }
    it{ should have_many :updates }
    it{ should have_many :notifications }
  end

  describe "validations" do
    %w[name user category video_url about headline goal expires_at].each do |field|
      it{ should validate_presence_of field }
    end
    it{ should ensure_length_of(:headline).is_at_most(140) }
  end

  describe ".recommended_for_home" do
    subject{ Project.recommended_for_home }

    before do
      Project.expects(:includes).with(:user, :category, :project_total).returns(Project)
      Project.expects(:recommended).returns(Project)
      Project.expects(:visible).returns(Project)
      Project.expects(:not_expired).returns(Project)
      Project.expects(:order).with('random()').returns(Project)
      Project.expects(:limit).with(4)
    end

    it{ should be_empty }
  end

  describe ".expiring_for_home" do
    subject{ Project.expiring_for_home(1) }

    before do
      Project.expects(:includes).with(:user, :category, :project_total).returns(Project)
      Project.expects(:visible).returns(Project)
      Project.expects(:expiring).returns(Project)
      Project.expects(:order).with('date(expires_at), random()').returns(Project)
      Project.expects(:where).with("coalesce(id NOT IN (?), true)", 1).returns(Project)
      Project.expects(:limit).with(3)
    end

    it{ should be_empty }
  end

  describe ".recent_for_home" do
    subject{ Project.recent_for_home(1) }

    before do
      Project.expects(:includes).with(:user, :category, :project_total).returns(Project)
      Project.expects(:visible).returns(Project)
      Project.expects(:recent).returns(Project)
      Project.expects(:not_expiring).returns(Project)
      Project.expects(:order).with('date(created_at) DESC, random()').returns(Project)
      Project.expects(:where).with("coalesce(id NOT IN (?), true)", 1).returns(Project)
      Project.expects(:limit).with(3)
    end

    it{ should be_empty }
  end

  describe ".not_expired" do
    before do
      @p = Factory(:project, :finished => false, :expires_at => (Date.today + 1.day))
      Factory(:project, :finished => false, :expires_at => (Date.today - 1.day))
      Factory(:project, :finished => true, :expires_at => (Date.today + 1.day))
    end
    subject{ Project.not_expired }
    it{ should == [@p] }
  end

  describe ".expiring" do
    before do
      @p = Factory(:project, :finished => false, :expires_at => (Date.today + 14.day))
      Factory(:project, :finished => false, :expires_at => (Date.today - 1.day))
      Factory(:project, :finished => true, :expires_at => (Date.today + 1.day))
      Factory(:project, :finished => false, :expires_at => (Date.today + 15.day))
    end
    subject{ Project.expiring }
    it{ should == [@p] }
  end

  describe ".not_expiring" do
    before do
      @p = Factory(:project, :finished => false, :expires_at => (Date.today + 15.day))
      Factory(:project, :finished => false, :expires_at => (Date.today - 1.day))
      Factory(:project, :finished => false, :expires_at => (Date.today - 1.day))
      Factory(:project, :finished => true, :expires_at => (Date.today + 1.day))
    end
    subject{ Project.not_expiring }
    it{ should == [@p] }
  end

  describe ".recent" do
    before do
      @p = Factory(:project, :created_at => (Date.today - 14.days))
      Factory(:project, :created_at => (Date.today - 15.days))
    end
    subject{ Project.recent }
    it{ should == [@p] }
  end

  describe "#pledged" do
    let(:project){ Project.new }
    subject{ project.pledged }
    context "when project_total is nil" do
      before do
        project.stubs(:project_total).returns(nil)
      end
      it{ should == 0 }
    end
    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stubs(:pledged).returns(10.0)
        project.stubs(:project_total).returns(project_total)
      end
      it{ should == 10.0 }
    end
  end

  describe "#total_backers" do
    let(:project){ Project.new }
    subject{ project.total_backers }
    context "when project_total is nil" do
      before do
        project.stubs(:project_total).returns(nil)
      end
      it{ should == 0 }
    end
    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stubs(:total_backers).returns(1)
        project.stubs(:project_total).returns(project_total)
      end
      it{ should == 1 }
    end
  end

  describe "#display_status" do
    let(:project){ Factory(:project) }
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

  describe "#vimeo" do

    def build_with_video url
      Factory.build(:project, :video_url => url)
    end

    subject{ build_with_video("http://vimeo.com/17298435") }

    its(:vimeo) do
      subject.id.should == "17298435"
      subject.embed_url.should == "http://player.vimeo.com/video/17298435"
    end

    it "should get vimeo image URL and store it" do
      Project.any_instance.unstub(:store_image_url)
      p = Factory.build(:project)
      p.vimeo.stubs(:info).returns({'id' => '1', 'thumbnail_large' => 'http://b.vimeocdn.com/ts/117/614/117614276_200.jpg'})
      p.vimeo.stubs(:id).returns('1')
      p.save!
      p.reload
      p.image_url.should == 'http://b.vimeocdn.com/ts/117/614/117614276_200.jpg'
    end

  end


  describe "#successful?" do
    let(:project){ Project.new :goal => 3000 }
    subject{ project.successful? }
    context "when pledged is inferior to goal" do
      before{ project.stubs(:pledged).returns(2999.99) }
      it{ should be_false }
    end
    context "when pledged is equal to goal" do
      before{ project.stubs(:pledged).returns(3000) }
      it{ should be_true }
    end
    context "when pledged is equal to goal" do
      before{ project.stubs(:pledged).returns(3001) }
      it{ should be_true }
    end
  end

  describe "#expired?" do
    subject{ project.expired? }
    context "when expires_at is in the future" do
      let(:project){ Project.new :expires_at => 2.seconds.from_now }
      it{ should be_false }
    end

    context "when expires_at is in the past" do
      let(:project){ Project.new :expires_at => 2.seconds.ago }
      it{ should be_true }
    end

    context "when project is finished" do
      let(:project){ Project.new :expires_at => 2.seconds.from_now, :finished => true }
      it{ should be_true }
    end
  end

  describe "#in_time?" do
    subject{ project.in_time? }
    context "when expires_at is in the future" do
      let(:project){ Project.new :expires_at => 2.seconds.from_now }
      it{ should be_true }
    end

    context "when expires_at is in the past" do
      let(:project){ Project.new :expires_at => 2.seconds.ago }
      it{ should be_false }
    end

    context "when project is finished" do
      let(:project){ Project.new :expires_at => 2.seconds.from_now, :finished => true }
      it{ should be_false }
    end
  end

  describe "status changes" do
    it "should be waiting confirmation until 3 weekdays after the deadline unless it is already successful" do
      p = Factory(:project, :goal => 100)
      time = Time.local 2011, 03, 04
      Time.stubs(:now).returns(time)
      p.successful?.should be_false
      p.expires_at = 1.minute.from_now
      p.waiting_confirmation?.should be_false
      p.expires_at = 4.weekdays_ago
      p.waiting_confirmation?.should be_false
      p.expires_at = 3.weekdays_ago - 1.minute
      p.waiting_confirmation?.should be_false
      p.expires_at = 3.weekdays_ago + 1.minute
      p.waiting_confirmation?.should be_true
      p.expires_at = 2.weekdays_ago
      p.waiting_confirmation?.should be_true
      p.stubs(:pledged).returns(100)
      p.successful?.should be_true
      p.expires_at = 3.weekdays_ago + 1.minute
      p.waiting_confirmation?.should be_false
      p.expires_at = 2.weekdays_ago
      p.waiting_confirmation?.should be_false
    end

  end

  describe "#finish!" do
    it "should generate credits for users when project finishes and didn't succeed" do
      user = Factory(:user)
      Factory(:notification_type, :name => 'backer_project_unsuccessful')
      project = Factory(:project, can_finish: true, finished: false, goal: 1000, expires_at: 1.day.ago)
      backer = Factory(:backer, project: project, user: user, value: 50)
      backer.confirm!
      project.finish!
      user.reload
      user.credits.should == 50
    end

    it "should store successful = true when finished and successful? is true" do
      Factory(:notification_type, :name => 'project_success')
      Factory(:notification_type, :name => 'backer_project_successful')
      project = Factory(:project, can_finish: true, finished: false, goal: 1000, expires_at: 1.day.ago)
      backer = Factory(:backer, project: project, value: 1000)
      project_total = mock()
      project_total.stubs(:pledged).returns(1000.0)
      project_total.stubs(:total_backers).returns(1)
      project.stubs(:project_total).returns(project_total)
      backer.confirm!
      project.successful?.should be_true
      project.successful.should be_false
      project.finish!
      project.reload
      project.successful?.should be_true
      project.successful.should be_true
    end

    it "should store successful = false when finished and successful? is false" do
      Factory(:notification_type, :name => 'backer_project_unsuccessful')
      project = Factory(:project, can_finish: true, finished: false, goal: 1000, expires_at: 1.day.ago)
      backer = Factory(:backer, project: project, value: 999)
      backer.confirm!
      project.successful?.should be_false
      project.successful.should be_false
      project.finish!
      project.reload
      project.successful?.should be_false
      project.successful.should be_false
    end

  end

  describe "display methods" do

    it "should have a display image" do
      p = Factory(:project)
      p.display_image.should_not be_empty
    end

    it "display_image should return image_url if it exists" do
      p = Factory(:project, :image_url => 'http://test.com/image')
      p.display_image.should == 'http://test.com/image'
    end

    it "should have a HTML-safe about_html, with textile and regular links" do
      p = Factory.build(:project)
      p.about = 'Foo Bar http://www.foo.bar <javascript>xss()</javascript>"Click here":http://click.here'
      p.about_html.should == '<p>Foo Bar <a href="http://www.foo.bar" target="_blank">http://www.foo.bar</a> &lt;javascript&gt;xss()&lt;/javascript&gt;<a target="_blank" href="http://click.here">Click here</a></p>'
    end

    it "should be able to display the remaining time with days, hours, minutes and seconds" do
      p = Factory.build(:project)
      time = Time.now
      Time.stubs(:now).returns(time)
      p.expires_at = 30.days.from_now
      p.time_to_go[:time].should == 30
      p.time_to_go[:unit].should == pluralize_without_number(30, I18n.t('datetime.prompts.day').downcase)
      p.expires_at = 1.day.from_now
      p.time_to_go[:time].should == 1
      p.time_to_go[:unit].should == pluralize_without_number(1, I18n.t('datetime.prompts.day').downcase)
      p.expires_at = 23.hours.from_now + 59.minutes + 59.seconds
      p.time_to_go[:time].should == 24
      p.time_to_go[:unit].should == pluralize_without_number(24, I18n.t('datetime.prompts.hour').downcase)
      p.expires_at = 1.hour.from_now
      p.time_to_go[:time].should == 1
      p.time_to_go[:unit].should == pluralize_without_number(1, I18n.t('datetime.prompts.hour').downcase)
      p.expires_at = 59.minutes.from_now
      p.time_to_go[:time].should == 59
      p.time_to_go[:unit].should == pluralize_without_number(59, I18n.t('datetime.prompts.minute').downcase)
      p.expires_at = 1.minute.from_now
      p.time_to_go[:time].should == 1
      p.time_to_go[:unit].should == pluralize_without_number(1, I18n.t('datetime.prompts.minute').downcase)
      p.expires_at = 59.seconds.from_now
      p.time_to_go[:time].should == 59
      p.time_to_go[:unit].should == pluralize_without_number(59, I18n.t('datetime.prompts.second').downcase)
      p.expires_at = 1.second.from_now
      p.time_to_go[:time].should == 1
      p.time_to_go[:unit].should == pluralize_without_number(1, I18n.t('datetime.prompts.second').downcase)
      p.expires_at = 0.seconds.from_now
      p.time_to_go[:time].should == 0
      p.time_to_go[:unit].should == pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)
      p.expires_at = 1.second.ago
      p.time_to_go[:time].should == 0
      p.time_to_go[:unit].should == pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)
      p.expires_at = 30.days.ago
      p.time_to_go[:time].should == 0
      p.time_to_go[:unit].should == pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)
    end

  end

  describe "#curated_pages" do

    it "should be able to be in more than one curated page" do
      cp = Factory.build(:curated_page)
      cp2 = Factory.build(:curated_page)
      p = Factory.build(:project, :curated_pages => [cp,cp2])
      p.curated_pages.size.should be 2
      p.should be_valid
    end

  end
end
