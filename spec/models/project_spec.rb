# coding: utf-8
require 'spec_helper'

describe Project do
  let(:project){ build(:project, goal: 3000) }
  let(:user){ create(:user) }
  let(:channel){ create(:channel, email: user.email, users: [ user ]) }
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
    it{ should allow_value('vimeo.com/12111').for(:video_url) }
    it{ should allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should_not allow_value('http://www.foo.bar').for(:video_url) }
    it{ should allow_value('testproject').for(:permalink) }
    it{ should_not allow_value('users').for(:permalink) }
  end

  describe ".visible" do
    before do
      [:draft, :rejected, :deleted, :in_analysis].each do |state|
        create(:project, state: state)
      end
      @project = create(:project, state: :online)
    end
    subject{ Project.visible }
    it{ should == [@project] }
  end

  describe '.state_names' do
    let(:states) { [:draft, :rejected, :online, :successful, :waiting_funds, :failed, :in_analysis] }

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

  describe '.by_goal' do
    subject { Project.by_goal(200) }

    before do
      @project_01 = create(:project, goal: 100)
      @project_02 = create(:project, goal: 200)

    end

    it { should = [@project_02] }
  end

  describe '.by_online_date' do
    subject { Project.by_online_date(Time.now.to_date.to_s) }

    before do
      @project_01 = create(:project, online_date: Time.now.to_s)
      @project_02 = create(:project, online_date: 2.weeks.ago)

    end

    it { should = [@project_01] }
  end

  describe '.by_expires_at' do
    subject { Project.by_expires_at('10/10/2013') }

    before do
      @project_01 = create(:project, online_date: '10/10/2013', online_days: 0)
      @project_02 = create(:project, online_date: '09/10/2013', online_days: 0)
    end

    it { should = [@project_01] }
  end

  describe '.order_by' do
    subject { Project.last.name }

    before do
      create(:project, name: 'lorem')
      #testing for sql injection
      Project.order_by("goal asc;update projects set name ='test';select * from projects ").first #use first so the sql is actually executed
    end

    it { should == 'lorem' }
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

  describe '.goal_between' do
    let(:start_at) { 100 }
    let(:ends_at) { 200 }
    subject { Project.goal_between(start_at, ends_at) }

    before do
      @project_01 = create(:project, goal: 100)
      @project_02 = create(:project, goal: 200)
      @project_03 = create(:project, created_at: 300)
    end

    it { should == [@project_01, @project_02] }
  end


  describe '.between_expires_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '21/01/2013' }
    subject { Project.between_expires_at(start_at, ends_at).order("id desc") }

    let(:project_01) { create(:project) }
    let(:project_02) { create(:project) }
    let(:project_03) { create(:project) }

    before do
      project_01.update_attributes({ online_date: '17/01/2013'.to_time, online_days: 0 })
      project_02.update_attributes({ online_date: '21/01/2013'.to_time, online_days: 0 })
      project_03.update_attributes({ online_date: '23/01/2013'.to_time, online_days: 0 })
    end

    it { should == [project_02, project_01] }
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
    let(:channel){create(:channel)}
    before do
      @p = create(:project, channels: [channel])
      create(:project, channels: [])
    end
    subject{ Project.from_channels([channel.id]) }
    it{ should == [@p] }
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

  describe "#last_channel" do
    let(:channel){ create(:channel) }
    let(:project){ create(:project, channels: [ create(:channel), channel ]) }
    subject{ project.last_channel }
    it{ should == channel }
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

    context "when project belongs to a channel" do
      let(:project) { channel_project }
      it{ should == user }
    end
  end

  describe "#notification_type" do
    subject { project.notification_type(:foo) }
    context "when project does not belong to any channel" do
      it { should eq(:foo) }
    end

    context "when project does belong to a channel" do
      let(:project) { channel_project }
      it{ should eq(:foo_channel) }
    end
  end
end
