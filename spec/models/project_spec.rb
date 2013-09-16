# coding: utf-8
require 'spec_helper'

describe Project do
  let(:project){ build(:project, goal: 3000) }
  let(:user){ create(:user) }
  let(:channel){ create(:channel, email: user.email, trustees: [ user ]) }
  let(:channel_project){ create(:project, channels: [ channel ]) }

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
    it{ should allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ should_not allow_value('http://www.foo.bar').for(:video_url) }
    it{ should allow_value('testproject').for(:permalink) }
    it{ should_not allow_value('users').for(:permalink) }
  end

  describe '.state_names' do
    let(:states) { [:draft, :rejected, :online, :successful, :waiting_funds, :failed] }

    subject { Project.state_names }

    it { should == states }
  end

  describe '.near_of' do
    before do
      mg_user = create(:user, address_state: 'MG')
      sp_user = create(:user, address_state: 'SP')
      3.times { create(:project, user: mg_user) }
      6.times { create(:project, user: sp_user) }
    end

    let(:state) { 'MG' }

    subject { Project.near_of(state) }

    it { should have(3).itens }
  end

  describe "by_permalink" do
    context "when project is deleted" do
      before do
        @p = create(:project, permalink: 'foo', state: 'deleted')
        create(:project, permalink: 'bar')
      end
      subject{ Project.by_permalink('foo') }
      it{ should == [] }
    end
    context "when project is not deleted" do
      before do
        @p = create(:project, permalink: 'foo')
        create(:project, permalink: 'bar')
      end
      subject{ Project.by_permalink('foo') }
      it{ should == [@p] }
    end
  end

  describe '.by_progress' do
    subject { Project.by_progress(20) }

    before do
      @project_01 = create(:project, goal: 100)
      @project_02 = create(:project, goal: 100)
      @project_03 = create(:project, goal: 100)

      create(:backer, value: 10, project: @project_01)
      create(:backer, value: 10, project: @project_01)
      create(:backer, value: 30, project: @project_02)
      create(:backer, value: 10, project: @project_03)
    end

    it { should have(2).itens }
  end

  describe '.between_created_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '20/01/2013' }
    subject { Project.between_created_at(start_at, ends_at) }

    before do
      @project_01 = create(:project, created_at: '19/01/2013')
      @project_02 = create(:project, created_at: '23/01/2013')
      @project_03 = create(:project, created_at: '26/01/2013')
    end

    it { should == [@project_01] }
  end

  describe '.between_expires_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '21/01/2013' }
    subject { Project.between_expires_at(start_at, ends_at) }

    let(:project_01) { create(:project) }
    let(:project_02) { create(:project) }
    let(:project_03) { create(:project) }

    before do
      project_01.update_attributes({ online_date: '19/01/2013'.to_time, online_days: 0 })
      project_02.update_attributes({ online_date: '23/01/2013'.to_time, online_days: 0 })
      project_03.update_attributes({ online_date: '26/01/2013'.to_time, online_days: 0 })
    end

    it { should == [project_01] }
  end

  describe '.to_finish' do
    before do
      Project.should_receive(:expired).and_call_original
      Project.should_receive(:with_states).with(['online', 'waiting_funds']).and_call_original
    end
    it "should call scope expired and filter states that can be finished" do
      Project.to_finish
    end
  end

  describe '.finish_projects!' do
    let(:project){ double('project', id: 1, name: 'test') }
    before do
      Project.should_receive(:to_finish).and_return([project])
      project.should_receive(:finish)
    end

    it "should iterate through to_finish projects and call finish to each one" do
      Project.finish_projects!
    end
  end

  describe ".backed_by" do
    before do
      backer = create(:backer, state: 'confirmed')
      @user = backer.user
      @project = backer.project
      # Another backer with same project and user should not create duplicate results
      create(:backer, user: @user, project: @project, state: 'confirmed')
      # Another backer with other project and user should not be in result
      create(:backer, state: 'confirmed')
      # Another backer with different project and same user but not confirmed should not be in result
      create(:backer, user: @user, state: 'pending')
    end
    subject{ Project.backed_by(@user.id) }
    it{ should == [@project] }
  end

  describe ".expired" do
    before do
      @p = create(:project, online_days: -1)
      create(:project, online_days: 1)
    end
    subject{ Project.expired}
    it{ should == [@p] }
  end

  describe ".not_expired" do
    before do
      @p = create(:project, online_days: 1)
      create(:project, online_days: -1)
    end
    subject{ Project.not_expired }
    it{ should == [@p] }
  end

  describe ".expiring" do
    before do
      @p = create(:project, online_date: Time.now, online_days: 13)
      create(:project, online_date: Time.now, online_days: -1)
    end
    subject{ Project.expiring }
    it{ should == [@p] }
  end

  describe ".not_expiring" do
    before do
      @p = create(:project, online_days: 15)
      create(:project, online_days: -1)
    end
    subject{ Project.not_expiring }
    it{ should == [@p] }
  end

  describe ".recent" do
    before do
      @p = create(:project, online_date: (Time.now - 4.days))
      create(:project, online_date: (Time.now - 15.days))
    end
    subject{ Project.recent }
    it{ should == [@p] }
  end

  describe ".from_channels" do
    before do
      @p = create(:project, channels: [create(:channel)])
      create(:project, channels: [])
    end
    subject{ Project.from_channels }
    it{ should == [@p] }
  end

  describe '#can_go_to_second_chance?' do
    let(:project) { create(:project, goal: 100, online_days: -3) }
    subject { project.can_go_to_second_chance? }

    before { create(:backer, value: 20, state: 'confirmed', project: project) }

    context 'when confirmed and pending backers reached 30% of the goal and in time to wait to wait' do
      before { create(:backer, value: 10, state: 'waiting_confirmation', project: project) }

      it { should be_true }
    end

    context 'when confirmed and pending backers reached less of 30% of the goal' do
      it { should be_false }
    end
  end

  describe '#reached_goal?' do
    let(:project) { create(:project, goal: 3000) }
    subject { project.reached_goal? }

    context 'when sum of all backers hit the goal' do
      before do
        create(:backer, value: 4000, project: project)
      end
      it { should be_true }
    end

    context "when sum of all backers don't hit the goal" do
      it { should be_false }
    end
  end

  describe '#in_time_to_wait?' do
    let(:backer) { create(:backer, state: 'waiting_confirmation') }
    subject { backer.project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { should be_true }
    end

    context 'when project expiration time is not more on time to wait' do
      let(:backer) { create(:backer, created_at: 1.week.ago) }
      it {should be_false}
    end
  end


  describe "#pg_search" do
    before { @p = create(:project, name: 'foo') }
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

  describe "#pledged_and_waiting" do
    subject{ project.pledged_and_waiting }
    before do
      @confirmed = create(:backer, value: 10, state: 'confirmed', project: project)
      @waiting = create(:backer, value: 10, state: 'waiting_confirmation', project: project)
      create(:backer, value: 100, state: 'refunded', project: project)
      create(:backer, value: 1000, state: 'pending', project: project)
    end
    it{ should == @confirmed.value + @waiting.value }
  end

  describe "#pledged" do
    subject{ project.pledged }
    context "when project_total is nil" do
      before do
        project.stub(:project_total).and_return(nil)
      end
      it{ should == 0 }
    end
    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stub(:pledged).and_return(10.0)
        project.stub(:project_total).and_return(project_total)
      end
      it{ should == 10.0 }
    end
  end

  describe "#total_payment_service_fee" do
    subject { project.total_payment_service_fee }

    context "when project_total is nil" do
      before { project.stub(:project_total).and_return(nil) }
      it { should == 0 }
    end

    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stub(:total_payment_service_fee).and_return(4.0)
        project.stub(:project_total).and_return(project_total)
      end

      it { should == 4.0 }
    end
  end

  describe "#total_backers" do
    subject{ project.total_backers }
    context "when project_total is nil" do
      before do
        project.stub(:project_total).and_return(nil)
      end
      it{ should == 0 }
    end
    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stub(:total_backers).and_return(1)
        project.stub(:project_total).and_return(project_total)
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
        its(:video){ should be_an_instance_of(VideoInfo::Providers::Vimeo) }
      end

      context 'video_url is an YouTube url' do
        before { project.video_url = "http://www.youtube.com/watch?v=Brw7bzU_t4c" }

        its(:video){ should be_an_instance_of(VideoInfo::Providers::Youtube) }
      end

      it 'caches the response object' do
        video_obj = VideoInfo.get(project.video_url)
        VideoInfo.should_receive(:get).once.and_return(video_obj)
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

    context "when online_date is nil" do
      let(:project){ Project.new online_date: nil, online_days: 0 }
      it{ should be_false }
    end

    context "when expires_at is in the future" do
      let(:project){ Project.new online_date: 2.days.from_now, online_days: 0 }
      it{ should be_false }
    end

    context "when expires_at is in the past" do
      let(:project){ Project.new online_date: 2.days.ago, online_days: 0 }
      it{ should be_true }
    end
  end

  describe "#in_time?" do
    subject{ project.in_time? }
    context "when expires_at is in the future" do
      let(:project){ Project.new online_date: 2.days.from_now, online_days: 0 }
      it{ should be_true }
    end

    context "when expires_at is in the past" do
      let(:project){ Project.new online_date: 2.days.ago, online_days: 0 }
      it{ should be_false }
    end
  end

  describe "#expires_at" do
    subject{ project.expires_at }
    context "when we do not have an online_date" do
      let(:project){ build(:project, online_date: nil, online_days: 0) }
      it{ should be_nil }
    end
    context "when we have an online_date" do
      let(:project){ build(:project, online_date: Time.now, online_days: 0) }
      it{ should == Time.zone.now.end_of_day }
    end
  end

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
      it{ should == {:time=>2, :unit=>"dias"} }
    end

    context "when there is less than 1 day to go" do
      let(:expires_at){ Time.zone.now + 13.hours }
      it{ should == {:time=>13, :unit=>"horas"} }
    end

    context "when there is less than 1 hour to go" do
      let(:expires_at){ Time.zone.now + 59.minutes }
      it{ should == {:time=>59, :unit=>"minutos"} }
    end
  end

  describe '#selected_rewards' do
    let(:project){ create(:project) }
    let(:reward_01) { create(:reward, project: project) }
    let(:reward_02) { create(:reward, project: project) }
    let(:reward_03) { create(:reward, project: project) }

    before do
      create(:backer, state: 'confirmed', project: project, reward: reward_01)
      create(:backer, state: 'confirmed', project: project, reward: reward_03)
    end

    subject { project.selected_rewards }
    it { should == [reward_01, reward_03] }
  end

  describe "#download_video_thumbnail" do
    let(:project){ build(:project) }
    before do
      project.should_receive(:download_video_thumbnail).and_call_original
      project.should_receive(:open).and_return(File.open("#{Rails.root}/spec/fixtures/image.png"))
      project.save!
    end

    it "should open the video_url and store it in video_thumbnail" do
      project.video_thumbnail.url.should == "/uploads/project/video_thumbnail/#{project.id}/image.png"
    end

  end

  describe '#pending_backers_reached_the_goal?' do
    let(:project) { create(:project, goal: 200) }

    before { project.stub(:pleged) { 100 } }

    subject { project.pending_backers_reached_the_goal? }

    context 'when reached the goal with pending backers' do
      before { 2.times { create(:backer, project: project, value: 120, state: 'waiting_confirmation') } }

      it { should be_true }
    end

    context 'when dont reached the goal with pending backers' do
      before { 2.times { create(:backer, project: project, value: 30, state: 'waiting_confirmation') } }

      it { should be_false }
    end
  end

  describe "#new_draft_recipient" do
    subject { project.new_draft_recipient }
    context "when project does not belong to any channel" do
      before do
        Configuration[:email_projects] = 'admin_projects@foor.bar'
        @user = create(:user, email: Configuration[:email_projects])
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
    let(:project) { create(:project, state: 'draft') }

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
        project.should_receive(:after_transition_of_draft_to_rejected)
        project.reject
        project
      end
      its(:rejected?){ should be_true }
    end

    describe '#push_to_trash' do
      let(:project) { FactoryGirl.create(:project, permalink: 'my_project', state: 'draft') }

      subject do
        project.push_to_trash
        project
      end

      its(:deleted?) { should be_true }
      its(:permalink) { should == "deleted_project_#{project.id}" }
    end

    describe '#approve' do
      subject do
        project.should_receive(:after_transition_of_draft_to_online)
        project.approve
        project
      end
      its(:online?){ should be_true }
      it('should call after transition method to notify the project owner'){ subject }
      it 'should persist the date of approvation' do
        project.approve
        project.online_date.should_not be_nil
      end
    end

    describe '#online?' do
      before { project.approve }
      subject { project.online? }
      it { should be_true }
    end

    describe '#finish' do
      let(:main_project) { create(:project, goal: 30_000, online_days: -1) }
      subject { main_project }

      context 'when project is not approved' do
        before do
          main_project.update_attributes state: 'draft'
        end
        its(:finish) { should be_false }
      end

      context 'when project is expired and the sum of the pending backers and confirmed backers dont reached the goal' do
        before do
          create(:backer, value: 100, project: main_project, created_at: 2.days.ago)
          main_project.finish
        end

        its(:failed?) { should be_true }
      end

      context 'when project is expired and the sum of the pending backers and confirmed backers reached 30% of the goal' do
        before do
          create(:backer, value: 100, project: main_project, created_at: 2.days.ago)
          create(:backer, value: 9_000, project: main_project, state: 'waiting_confirmation')
          main_project.finish
        end

        its(:waiting_funds?) { should be_true }
      end

      context 'when project is expired and have recent backers without confirmation' do
        before do
          create(:backer, value: 30_000, project: subject, state: 'waiting_confirmation')
          main_project.finish
        end

        its(:waiting_funds?) { should be_true }
      end

      context 'when project already hit the goal and passed the waiting_funds time' do
        before do
          main_project.update_attributes state: 'waiting_funds'
          subject.stub(:pending_backers_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          subject.online_date = 2.weeks.ago
          subject.online_days = 0
          subject.finish
        end
        its(:successful?) { should be_true }
      end

      context 'when project already hit the goal and still is in the waiting_funds time' do
        before do
          subject.stub(:pending_backers_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          create(:backer, project: main_project, user: user, value: 20, state: 'waiting_confirmation')
          main_project.update_attributes state: 'waiting_funds'
          subject.finish
        end
        its(:successful?) { should be_false }
      end

      context 'when project not hit the goal' do
        let(:user) { create(:user) }
        let(:backer) { create(:backer, project: main_project, user: user, value: 20, payment_token: 'ABC') }

        before do
          backer
          subject.online_date = 2.weeks.ago
          subject.online_days = 0
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

  describe '#permalink_on_routes?' do
    it 'should allow a unique permalink' do
      Project.permalink_on_routes?('permalink_test').should be_false
    end

    it 'should not allow a permalink to be one of catarse\'s routes' do
      Project.permalink_on_routes?('projects').should be_true
    end
  end
end
