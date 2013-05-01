# coding: utf-8
require 'spec_helper'

describe Project do
  let(:project){ Project.new :goal => 3000 }
  let(:user){ FactoryGirl.create(:user) }
  let(:channel){ FactoryGirl.create(:channel, email: user.email, trustees: [ user ]) }
  let(:channel_project){ FactoryGirl.create(:project, channels: [ channel ]) }

  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :category }
    it{ should have_many :backers }
    it{ should have_one  :project_total }
    it{ should have_many :rewards }
    it{ should have_many :updates }
    it{ should have_many :notifications }
    it{ should have_and_belong_to_many :channels }
  end

  describe "validations" do
    %w[name user category about headline goal permalink].each do |field|
      it{ should validate_presence_of field }
    end
    it{ should ensure_length_of(:headline).is_at_most(140) }
    it{ should validate_format_of(:video_url).with(Regexp.union(/https?:\/\/(www\.)?vimeo.com\/(\d+)/, VideoInfo::Youtube.new('').regex)).with_message(I18n.t('project.video_regex_validation')) }
  end

  describe '.state_names' do
    let(:states) { [:draft, :rejected, :online, :successful, :waiting_funds, :failed] }

    subject { Project.state_names }

    it { should == states }
  end

  describe '.by_state' do
    before do
      @project_01 = FactoryGirl.create(:project, state: 'online')
      @project_02 = FactoryGirl.create(:project, state: 'failed')
      @project_03 = FactoryGirl.create(:project, state: 'successful')
    end

    context 'get all projects that is online' do
      subject { Project.by_state('online') }

      it { should == [@project_01] }
    end

    context 'get all projects that is failed' do
      subject { Project.by_state('failed') }

      it { should == [@project_02] }
    end

    context 'get all projects that is successful' do
      subject { Project.by_state('successful') }

      it { should == [@project_03] }
    end
  end

  describe '.by_progress' do
    subject { Project.by_progress(20) }

    before do
      @project_01 = FactoryGirl.create(:project, goal: 100)
      @project_02 = FactoryGirl.create(:project, goal: 100)
      @project_03 = FactoryGirl.create(:project, goal: 100)

      FactoryGirl.create(:backer, value: 10, project: @project_01)
      FactoryGirl.create(:backer, value: 10, project: @project_01)
      FactoryGirl.create(:backer, value: 30, project: @project_02)
      FactoryGirl.create(:backer, value: 10, project: @project_03)
    end

    it { should have(2).itens }
  end

  describe '.between_created_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '20/01/2013' }
    subject { Project.between_created_at(start_at, ends_at) }

    before do
      @project_01 = FactoryGirl.create(:project, created_at: '19/01/2013')
      @project_02 = FactoryGirl.create(:project, created_at: '23/01/2013')
      @project_03 = FactoryGirl.create(:project, created_at: '26/01/2013')
    end

    it { should == [@project_01] }
  end

  describe '.between_expires_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '21/01/2013' }
    subject { Project.between_expires_at(start_at, ends_at) }

    let(:project_01) { FactoryGirl.create(:project) }
    let(:project_02) { FactoryGirl.create(:project) }
    let(:project_03) { FactoryGirl.create(:project) }

    before do
      project_01.update_attributes({ expires_at: '19/01/2013' })
      project_02.update_attributes({ expires_at: '23/01/2013' })
      project_03.update_attributes({ expires_at: '26/01/2013' })
    end

    it { should == [project_01] }
  end

  describe '.finish_projects!' do
    before do
      @project_01 = FactoryGirl.create(:project, online_days: -1, goal: 300, state: 'online')
      @project_02 = FactoryGirl.create(:project, online_days: 5, goal: 300, state: 'online')
      @project_03 = FactoryGirl.create(:project, online_days: -7, goal: 300, state: 'waiting_funds')
      backer = FactoryGirl.create(:backer, project: @project_03, value: 3000, confirmed: true)
      pending_backer = FactoryGirl.create(:backer, project: @project_01, value: 340, confirmed: false, payment_token: 'ABC')
      @project_04 = FactoryGirl.create(:project, online_days: -7, goal: 300, state: 'waiting_funds')
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
      backer = FactoryGirl.create(:backer, confirmed: true)
      @user = backer.user
      @project = backer.project
      # Another backer with same project and user should not create duplicate results
      FactoryGirl.create(:backer, user: @user, project: @project, confirmed: true)
      # Another backer with other project and user should not be in result
      FactoryGirl.create(:backer, confirmed: true)
      # Another backer with different project and same user but not confirmed should not be in result
      FactoryGirl.create(:backer, user: @user, confirmed: false)
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
      @p = FactoryGirl.create(:project, :online_days => -1)
      FactoryGirl.create(:project, :online_days => 1)
    end
    subject{ Project.expired}
    it{ should == [@p] }
  end

  describe ".not_expired" do
    before do
      @p = FactoryGirl.create(:project, :online_days => 1)
      FactoryGirl.create(:project, :online_days => -1)
    end
    subject{ Project.not_expired }
    it{ should == [@p] }
  end

  describe ".expiring" do
    before do
      @p = FactoryGirl.create(:project, :online_days => 14)
      FactoryGirl.create(:project, :online_days => -1)
    end
    subject{ Project.expiring }
    it{ should == [@p] }
  end

  describe ".not_expiring" do
    before do
      @p = FactoryGirl.create(:project, :online_days => 15)
      FactoryGirl.create(:project, :online_days => -1)
    end
    subject{ Project.not_expiring }
    it{ should == [@p] }
  end

  describe ".recent" do
    before do
      @p = FactoryGirl.create(:project, :online_date => (Time.now - 14.days))
      FactoryGirl.create(:project, :online_date => (Time.now - 15.days))
    end
    subject{ Project.recent }
    it{ should == [@p] }
  end

  describe ".online" do
    before do
      @p = FactoryGirl.create(:project, state: 'online')
      FactoryGirl.create(:project)
    end
    subject{ Project.online}
    it{ should == [@p] }
  end

  describe '#can_go_to_second_chance?' do
    let(:project) { FactoryGirl.create(:project, goal: 100) }
    subject { project.can_go_to_second_chance? }

    before { FactoryGirl.create(:backer, value: 20, confirmed: true, project: project) }

    context 'when confirmed and pending backers reached 30% of the goal' do
      before { FactoryGirl.create(:backer, value: 10, confirmed: false, payment_token: 'ABC', project: project) }

      it { should be_true }
    end

    context 'when confirmed and pending backers reached less of 30% of the goal' do
      it { should be_false }
    end
  end

  describe '#reached_goal?' do
    let(:project) { FactoryGirl.create(:project, goal: 3000) }
    subject { project.reached_goal? }

    context 'when sum of all backers hit the goal' do
      before do
        FactoryGirl.create(:backer, value: 4000, project: project)
      end
      it { should be_true }
    end

    context "when sum of all backers don't hit the goal" do
      it { should be_false }
    end
  end

  describe '#in_time_to_wait?' do
    let(:backer) { FactoryGirl.create(:backer, confirmed: false, payment_token: 'token') }
    subject { backer.project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { should be_true }
    end

    context 'when project expiration time is not more on time to wait' do
      let(:backer) { FactoryGirl.create(:backer, created_at: 1.week.ago) }
      it {should be_false}
    end
  end


  describe "#pg_search" do
    before { @p = FactoryGirl.create(:project, name: 'foo') }
    context "when project exists" do
      subject{ [Project.pg_search('foo'), Project.pg_search('fóõ')] }
      it{ should == [[@p],[@p]] }
    end
    context "when project is not found" do
      subject{ Project.pg_search('lorem') }
      it{ should == [] }
    end
  end

  describe "#progress" do
    subject{ project.progress }
    let(:pledged){ 0.0 }
    let(:goal){ 0.0 }
    before do
        project.stubs(:pledged).returns(pledged)
        project.stubs(:goal).returns(goal)
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
      it{ should == 100 }
    end

    context "when goal is 0.0 and pledged is 0.0" do
      it{ should == 0 }
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

  describe "#video" do
    subject { project }

    context "video_url is blank" do
      before { project.video_url = ''}

      its(:video){ should be_nil}
    end

    context 'video_url is defined' do
      before { project.video_url = "http://vimeo.com/17298435" }

      context 'video_url is a Vimeo url' do
        its(:video){ should be_an_instance_of(VideoInfo::Vimeo) }
      end

      context 'video_url is an YouTube url' do
        before { project.video_url = "http://www.youtube.com/watch?v=Brw7bzU_t4c" }

        its(:video){ should be_an_instance_of(VideoInfo::Youtube) }
      end

      it 'caches the response object' do
        video_obj = VideoInfo.get(project.video_url)
        VideoInfo.expects(:get).once.returns(video_obj)
        5.times { project.video }
      end
    end

    context 'video_url changes' do
      before { project.video_url = 'http://vimeo.com/17298435' }

      it 'maintain cached version' do
        project.video_url = 'http://vimeo.com/59205360'
        project.video.video_id = '17298435'
      end
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
    p = FactoryGirl.build(:project)
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

  describe '#selected_rewards' do
    let(:project){ FactoryGirl.create(:project) }
    let(:reward_01) { FactoryGirl.create(:reward, project: project) }
    let(:reward_02) { FactoryGirl.create(:reward, project: project) }
    let(:reward_03) { FactoryGirl.create(:reward, project: project) }

    before do
      FactoryGirl.create(:backer, project: project, reward: reward_01)
      FactoryGirl.create(:backer, project: project, reward: reward_03)
    end

    subject { project.selected_rewards }
    it { should == [reward_01, reward_03] }
  end

  describe "#download_video_thumbnail" do
    let(:project){ FactoryGirl.build(:project) }
    before do
      Project.any_instance.unstub(:download_video_thumbnail)
      Project.any_instance.expects(:open).with(project.video.thumbnail_large).returns(File.open("#{Rails.root}/spec/fixtures/image.png"))
      project.save!
    end

    it "should open the video_url and store it in video_thumbnail" do
      project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
    end

  end

  describe '#pending_backers_reached_the_goal?' do
    let(:project) { FactoryGirl.create(:project, goal: 200) }

    before { project.stubs(:pleged) { 100 } }

    subject { project.pending_backers_reached_the_goal? }

    context 'when reached the goal with pending backers' do
      before { 2.times { FactoryGirl.create(:backer, project: project, value: 120, confirmed: false, payment_token: 'ABC') } }

      it { should be_true }
    end

    context 'when dont reached the goal with pending backers' do
      before { 2.times { FactoryGirl.create(:backer, project: project, value: 30, confirmed: false, payment_token: 'ABC') } }

      it { should be_false }
    end
  end

  describe "#new_draft_recipient" do
    subject { project.new_draft_recipient }
    context "when project does not belong to any channel" do
      before do
        Configuration[:email_projects] = 'admin_projects@foor.bar'
        @user = FactoryGirl.create(:user, email: Configuration[:email_projects])
      end
      it{ should == @user }
    end

    context "when project does belong to a channel" do
      let(:project) { channel_project }
      it{ should == user }
    end
  end

  describe "#new_draft_project_notification_type" do
    subject{ project.new_draft_project_notification_type }

    context "when project does not belong to any channel" do
      it{ should == :new_draft_project }
    end

    context "when project does belong to a channel" do
      let(:project) { channel_project }
      it{ should == :new_draft_project_channel }
    end
  end

  describe "#new_project_received_notification_type" do
    subject{ project.new_project_received_notification_type }

    context "when project does not belong to any channel" do
      it{ should == :project_received }
    end

    context "when project does belong to a channel" do
      let(:project) { channel_project }
      it{ should == :project_received_channel }
    end
  end

  describe "state machine" do
    let(:project) { FactoryGirl.create(:project) }

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
      let(:main_project) { FactoryGirl.create(:project, goal: 30_000, online_days: -1) }
      subject { main_project }

      context 'when project is not approved' do
        its(:finish) { should be_false }
      end

      context 'when project is approved' do
        before do
          subject.approve
        end

        context 'when project is expired and the sum of the pending backers and confirmed backers dont reached the goal' do
          before do
            FactoryGirl.create(:backer, value: 100, project: subject, created_at: 2.days.ago)
            subject.finish
          end

          its(:failed?) { should be_true }
        end

        context 'when project is expired and the sum of the pending backers and confirmed backers reached 30% of the goal' do
          before do
            FactoryGirl.create(:backer, value: 100, project: subject, created_at: 2.days.ago)
            FactoryGirl.create(:backer, value: 9_000, project: subject, payment_token: 'ABC', confirmed: false)

            subject.finish
          end

          its(:waiting_funds?) { should be_true }
        end

        context 'when project is expired and have recent backers without confirmation' do
          before do
            FactoryGirl.create(:backer, value: 30_000, project: subject, payment_token: 'ABC', confirmed: false)
            subject.finish
          end

          its(:waiting_funds?) { should be_true }
        end

        context 'when project already hit the goal' do
          before do
            subject.stubs(:pending_backers_reached_the_goal?).returns(true)
            subject.stubs(:reached_goal?).returns(true)
            subject.finish
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
              FactoryGirl.create(:backer, project: subject, user: user, value: 20, payment_token: 'ABC', confirmed: false)
              subject.finish
            end

            its(:successful?) { should be_false }
          end
        end

        context 'when project not hit the goal' do
          let(:user) { FactoryGirl.create(:user) }
          let(:backer) { FactoryGirl.create(:backer, project: subject, user: user, value: 20, payment_token: 'ABC') }

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
      end
    end

  end

end
