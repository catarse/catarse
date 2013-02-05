# coding: utf-8
require 'spec_helper'

describe Project do
  let(:project){ Project.new :goal => 3000 }

  describe "associations" do
    it{ should have_many :backers }
    it{ should have_one  :project_total }
    it{ should have_many :rewards }
    it{ should have_many :updates }
    it{ should have_many :notifications }
  end

  describe "validations" do
    %w[name user category about headline goal].each do |field|
      it{ should validate_presence_of field }
    end
    it{ should ensure_length_of(:headline).is_at_most(140) }
  end

  describe '.finish_projects!' do
    before do
      @project_01 = Factory(:project, online_days: -1, goal: 300, state: 'online')
      @project_02 = Factory(:project, online_days: 5, goal: 300, state: 'online')
      @project_03 = Factory(:project, online_days: -7, goal: 300, state: 'waiting_funds')
      backer = Factory(:backer, project: @project_03, value: 3000, confirmed: true)
      @project_04 = Factory(:project, online_days: -7, goal: 300, state: 'waiting_funds')
      Project.finish_projects!
      @project_01.reload
      @project_02.reload
      @project_03.reload
      @project_04.reload
    end

    it 'should turn state to waiting funds' do
      @project_01.waiting_funds?.should be_true
    end

    it 'should not change state when project is not expired and already reached the goal' do
      @project_02.online?.should be_true
    end

    it 'should change state to successful when project already in waiting funds and reached the goal' do
      @project_03.successful?.should be_true
    end

    it 'should change state to failed when project already in waiting funds and not reached the goal' do
      @project_04.failed?.should be_true
    end
  end

  describe ".backed_by" do
    before do
      backer = Factory(:backer, confirmed: true)
      @user = backer.user
      @project = backer.project
      # Another backer with same project and user should not create duplicate results
      Factory(:backer, user: @user, project: @project, confirmed: true) 
      # Another backer with other project and user should not be in result
      Factory(:backer, confirmed: true) 
      # Another backer with different project and same user but not confirmed should not be in result
      Factory(:backer, user: @user, confirmed: false) 
    end
    subject{ Project.backed_by(@user.id) }
    it{ should == [@project] }
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

  describe ".expired" do
    before do
      @p = Factory(:project, :online_days => -1)
      Factory(:project, :online_days => 1)
    end
    subject{ Project.expired}
    it{ should == [@p] }
  end

  describe ".not_expired" do
    before do
      @p = Factory(:project, :online_days => 1)
      Factory(:project, :online_days => -1)
    end
    subject{ Project.not_expired }
    it{ should == [@p] }
  end

  describe ".expiring" do
    before do
      @p = Factory(:project, :online_days => 14)
      Factory(:project, :online_days => -1)
    end
    subject{ Project.expiring }
    it{ should == [@p] }
  end

  describe ".not_expiring" do
    before do
      @p = Factory(:project, :online_days => 15)
      Factory(:project, :online_days => -1)
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

  describe ".online" do
    before do
      @p = Factory(:project, state: 'online')
      Factory(:project)
    end
    subject{ Project.online}
    it{ should == [@p] }
  end

  describe '#reached_goal?' do
    let(:project) { Factory(:project, goal: 3000) }
    subject { project.reached_goal? }

    context 'when sum of all backers hit the goal' do
      before do
        Factory(:backer, value: 4000, project: project)
      end
      it { should be_true }
    end

    context "when sum of all backers don't hit the goal" do
      it { should be_false }
    end
  end

  describe '#in_time_to_wait?' do
    let(:project) { Factory(:project, expires_at: 1.day.ago) }
    subject { project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { should be_true }
    end

    context 'when project expiration time is not more on time to wait' do
      before do
        project.update_column :expires_at, 1.week.ago
        project.reload
      end
      it {should be_false}
    end
  end


  describe "#pg_search" do
    before { @p = Factory(:project, name: 'foo') }
    context "when project exists" do
      subject{ [Project.pg_search('foo'), Project.pg_search('fóõ')] }
      it{ should == [[@p],[@p]] }
    end
    context "when project is not found" do
      subject{ Project.pg_search('lorem') }
      it{ should == [] }
    end
  end

  describe "#pledged" do
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

  describe "#vimeo" do
    def build_with_video url
      Factory.build(:project, :video_url => url)
    end

    subject{ build_with_video("http://vimeo.com/17298435") }

    its(:vimeo) do
      subject.id.should == "17298435"
      subject.embed_url.should == "http://player.vimeo.com/video/17298435"
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
  end

  it "should return time_to_go acording to expires_at" do
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

  describe "#users_who_backed" do
    subject{ project.users_who_backed }
    before do
      User.expects(:who_backed_project).with(project.id).returns('users')
    end
    it{ should == 'users' }
  end

  describe "#can_back?" do
    subject{ project.can_back? }

    context "when project is approved" do
      let(:project) { Factory(:project, state: 'online') }
      it{ should be_true }
    end

    context "when project is successful" do
      let(:project) { Factory(:project, state: 'successful') }
      it{ should be_false }
    end

    context "when project is not visible" do
      let(:project) { Factory(:project) }
      it{ should be_false }
    end

    context "when project is waiting funds" do
      let(:project) { Factory(:project, state: 'waiting_funds') }
      it{ should be_false }
    end

    context "when project is expired" do
      before do
        project.expires_at = Time.now - 1.day
        project.save!
      end
      let(:project) { Factory(:project, state: 'successful') }
      it{ should be_false }
    end

    context "when project is rejected" do
      let(:project) { Factory(:project, state: 'rejected') }
      it{ should be_false }
    end
  end

  describe '#selected_rewards' do
    let(:project){ Factory(:project) }
    let(:reward_01) { Factory(:reward, project: project) }
    let(:reward_02) { Factory(:reward, project: project) }
    let(:reward_03) { Factory(:reward, project: project) }

    before do
      Factory(:backer, project: project, reward: reward_01)
      Factory(:backer, project: project, reward: reward_03)
    end

    subject { project.selected_rewards }
    it { should == [reward_01, reward_03] }
  end

  describe "#download_video_thumbnail" do
    let(:project){ Factory.build(:project) }
    before do
      Project.any_instance.unstub(:download_video_thumbnail)
      Project.any_instance.expects(:open).with(project.vimeo.thumbnail).returns(File.open("#{Rails.root}/spec/fixtures/image.png"))
      project.save!
    end

    it "should open the video_url and store it in video_thumbnail" do
      project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
    end

  end

  describe "state machine" do
    let(:project) { Factory(:project) }

    describe '#draft?' do
      subject { project.draft? }
      context "when project is new" do
        it { should be_true }
      end
    end

    describe '.push_to_draft' do
      subject do
        project.reject
        project.push_to_draft
        project
      end
      its(:draft?){ should be_true }
    end

    describe '#rejected?' do
      subject { project.rejected? }
      before do
        project.reject
      end
      context 'when project is not accepted' do
        it { should be_true }
      end
    end

    describe '#reject' do
      subject do
        project.expects(:after_transition_of_draft_to_rejected)
        project.reject
        project
      end
      its(:rejected?){ should be_true }
    end

    describe '#approve' do
      subject do 
        project.expects(:after_transition_of_draft_to_online)
        project.approve
        project
      end
      its(:online?){ should be_true }
      it('should call after transition method to notify the project owner'){ subject }
      it 'should persist the date of approvation' do
        project.approve
        project.online_date.should_not be_nil
      end
      it 'when approves after days should refresh the expires_at' do
        project.update_column :expires_at, 3.days.from_now
        project.approve
        project.expires_at.to_s.should_not == 3.days.from_now.to_s
      end
    end

    describe '#online?' do
      before { project.approve }
      subject { project.online? }
      it { should be_true }
    end

    describe '#finish' do
      let(:main_project) { Factory(:project, goal: 30_000, online_days: -1) }
      subject { main_project }

      context 'when project is not approved' do
        its(:finish) { should be_false }
      end

      context 'when project is approved' do
        before do
          subject.approve
          subject.finish
        end

        context 'when project is expired and have recent backers without confirmation' do
          before do
            backer = Factory(:backer, value: 100, project: subject, created_at: 2.days.ago)
          end
          its(:waiting_funds?) { should be_true }
        end

        context 'when project already hit the goal' do
          before do
            project_total = mock()
            project_total.stubs(:pledged).returns(30000.0)
            subject.stubs(:project_total).returns(project_total)
          end

          context "and pass the waiting fund time" do
            before do
              subject.update_column :expires_at, 2.weeks.ago
              subject.finish
            end
            its(:successful?) { should be_true }
          end

          context "and still in waiting fund time" do
            before do
              subject.finish
            end

            its(:successful?) { should be_false }
          end
        end

        context 'when project not hit the goal' do
          context "and pass the waiting fund time" do
            let(:user) { Factory(:user) }
            let(:backer) { Factory(:backer, project: subject, user: user, value: 20) }

            before do
              subject.update_column :expires_at, 2.weeks.ago
              subject.finish
            end

            its(:failed?) { should be_true }

            it "should generate credits for users" do
              backer.confirm!
              user.reload
              user.credits.should == 20
            end
          end

          context "and still in waiting fund time" do
            its(:failed?) { should be_false }
            its(:waiting_funds?) { should be_true }
          end
        end
      end
    end

  end

end
