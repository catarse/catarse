# coding: utf-8
require 'spec_helper'

describe Project do
  let(:project){ build(:project, goal: 3000) }
  let(:user){ create(:user) }
  let(:channel){ create(:channel, users: [ user ]) }
  let(:channel_project){ create(:project, channels: [ channel ]) }

  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :category }
    it{ should have_many :contributions }
    it{ should have_one  :project_total }
    it{ should have_many :rewards }
    it{ should have_many :posts }
    it{ should have_many :notifications }
    it{ should have_and_belong_to_many :channels }
  end

  describe "validations" do
    %w[name user category about headline goal permalink].each do |field|
      it{ should validate_presence_of field }
    end
    it{ should validate_numericality_of(:goal) }
    it{ should allow_value(10).for(:goal) }
    it{ should_not allow_value(8).for(:goal) }
    it{ should ensure_length_of(:headline).is_at_most(140) }
    it{ should allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('vimeo.com/12111').for(:video_url) }
    it{ should allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should_not allow_value('http://www.foo.bar').for(:video_url) }
    it{ should allow_value('testproject').for(:permalink) }
    it{ should allow_value(1).for(:online_days) }
    it{ should_not allow_value(0).for(:online_days) }
    it{ should_not allow_value(61).for(:online_days) }
    it{ should_not allow_value('users').for(:permalink) }
  end

  describe ".expiring_in_less_of" do
    subject { Project.expiring_in_less_of('7 days') }

    before do
      @project_01 = create(:project, state: 'online', online_date: DateTime.now, online_days: 3)
      @project_02 = create(:project, state: 'online', online_date: DateTime.now, online_days: 30)
      @project_03 = create(:project, state: 'draft')
      @project_04 = create(:project, state: 'online', online_date: DateTime.now, online_days: 3)
    end

    it "should return a collection with projects that is expiring time less of the time in param" do
      should == [@project_01, @project_04]
    end
  end

  describe ".with_contributions_confirmed_today" do
    let(:project_01) { create(:project, state: 'online') }
    let(:project_02) { create(:project, state: 'online') }
    let(:project_03) { create(:project, state: 'online') }

    subject { Project.with_contributions_confirmed_today }

    before do
      project_01
      project_02
      project_03
    end

    context "when have confirmed contributions today" do
      before do

        #TODO: need to investigate this timestamp issue when
        # use DateTime.now or Time.now
        create(:contribution, state: 'confirmed', project: project_01, confirmed_at: Time.now )
        create(:contribution, state: 'confirmed', project: project_02, confirmed_at: 2.days.ago )
        create(:contribution, state: 'confirmed', project: project_03, confirmed_at: Time.now )
      end

      it { should have(2).items }
      it { subject.include?(project_02).should be_false }
    end

    context "when does not have any confirmed contribution today" do
      before do
        create(:contribution, state: 'confirmed', project: project_01, confirmed_at: 1.days.ago )
        create(:contribution, state: 'confirmed', project: project_02, confirmed_at: 2.days.ago )
        create(:contribution, state: 'confirmed', project: project_03, confirmed_at: 5.days.ago )
      end

      it { should have(0).items }
    end
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

  describe ".by_permalink" do
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

      create(:contribution, value: 10, project: @project_01)
      create(:contribution, value: 10, project: @project_01)
      create(:contribution, value: 30, project: @project_02)
      create(:contribution, value: 10, project: @project_03)
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

  describe '.video_url' do
    before do
      CatarseSettings[:minimum_goal_for_video] = 5000
    end
    context 'when goal is above minimum' do
      subject { @project_01 }

      before do
        @project_01 = create(:project, goal: 6000, state: 'online')
      end

      it{ should_not allow_value(nil).for(:video_url) }
    end

    context 'when goal is below minimum' do
      subject { @project_02 }

      before do
        CatarseSettings[:minumum_goal_for_video] = 5000
        @project_02 = create(:project, goal: 4000, state: 'online')
      end

      it{ should allow_value(nil).for(:video_url) }
    end

    context 'when goal is minimum' do
      subject { @project_03 }

      before do
        @project_03 = build(:project, goal: 5000, state: 'online', video_url: nil)
      end

      it{ should_not allow_value(nil).for(:video_url) }
    end
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
      @project_01 = create(:project, online_date: '10/10/2013', online_days: 1)
      @project_02 = create(:project, online_date: '09/10/2013', online_days: 1)
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
    subject { Project.goal_between(start_at, ends_at).order(:id) }

    before do
      @project_01 = create(:project, goal: 100)
      @project_02 = create(:project, goal: 200)
      @project_03 = create(:project, created_at: 300)
    end

    it { should == [@project_01, @project_02] }
  end


  describe '.between_expires_at' do
    let(:start_at) { '17/01/2013' }
    let(:ends_at) { '22/01/2013' }
    subject { Project.between_expires_at(start_at, ends_at).order("id desc") }

    let(:project_01) { create(:project) }
    let(:project_02) { create(:project) }
    let(:project_03) { create(:project) }

    before do
      project_01.update_attributes({ online_date: '17/01/2013', online_days: 1 })
      project_02.update_attributes({ online_date: '21/01/2013', online_days: 1 })
      project_03.update_attributes({ online_date: '23/01/2013', online_days: 1 })
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

  describe ".expired" do
    before do
      @p = create(:project, online_days: 1, online_date: Time.now - 2.days)
      create(:project, online_days: 1)
    end
    subject{ Project.expired}
    it{ should == [@p] }
  end

  describe ".not_expired" do
    before do
      @p = create(:project, online_days: 1)
      create(:project, online_days: 1, online_date: Time.now - 2.days)
    end
    subject{ Project.not_expired }
    it{ should == [@p] }
  end

  describe ".expiring" do
    before do
      @p = create(:project, online_date: Time.now, online_days: 13)
      create(:project, online_date: Time.now, online_days: 1, online_date: Time.now - 2.days)
    end
    subject{ Project.expiring }
    it{ should == [@p] }
  end

  describe ".not_expiring" do
    before do
      @p = create(:project, online_days: 15)
      create(:project, online_days: 1, online_date: Time.now - 2.days)
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

  describe "send_verify_moip_account_notification" do
    before do
      @p = create(:project, state: 'online', online_date: DateTime.now, online_days: 3)
      create(:project, state: 'draft')
    end

    it "should create notification for all projects that is expiring" do
      ProjectNotification.should_receive(:notify_once).
        with(:verify_moip_account, @p.user, @p, {from_email: CatarseSettings[:email_payments]})
      Project.send_verify_moip_account_notification
    end
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

    context 'when sum of all contributions hit the goal' do
      before do
        create(:contribution, value: 4000, project: project)
      end
      it { should be_true }
    end

    context "when sum of all contributions don't hit the goal" do
      it { should be_false }
    end
  end

  describe '#in_time_to_wait?' do
    let(:contribution) { create(:contribution, state: 'waiting_confirmation') }
    subject { contribution.project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { should be_true }
    end

    context 'when project expiration time is not more on time to wait' do
      let(:contribution) { create(:contribution, created_at: 1.week.ago) }
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

  describe "#pledged_and_waiting" do
    subject{ project.pledged_and_waiting }
    before do
      @confirmed = create(:contribution, value: 10, state: 'confirmed', project: project)
      @waiting = create(:contribution, value: 10, state: 'waiting_confirmation', project: project)
      create(:contribution, value: 100, state: 'refunded', project: project)
      create(:contribution, value: 1000, state: 'pending', project: project)
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

  describe "#total_contributions" do
    subject{ project.total_contributions }
    context "when project_total is nil" do
      before do
        project.stub(:project_total).and_return(nil)
      end
      it{ should == 0 }
    end
    context "when project_total exists" do
      before do
        project_total = mock()
        project_total.stub(:total_contributions).and_return(1)
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
      let(:project){ build(:project, online_date: 3.days.ago, online_days: 1) }
      before{project.save!}
      it{ should be_true }
    end
  end

  describe "#expires_at" do
    subject{ project.expires_at }
    context "when we do not have an online_date" do
      let(:project){ build(:project, online_date: nil, online_days: 1) }
      it{ should be_nil }
    end
    context "when we have an online_date" do
      let(:project){ create(:project, online_date: Time.now, online_days: 1)}
      before{project.save!}
      it{ should == Time.zone.tomorrow.end_of_day.to_s(:db) }
    end
  end

  describe '#selected_rewards' do
    let(:project){ create(:project) }
    let(:reward_01) { create(:reward, project: project) }
    let(:reward_02) { create(:reward, project: project) }
    let(:reward_03) { create(:reward, project: project) }

    before do
      create(:contribution, state: 'confirmed', project: project, reward: reward_01)
      create(:contribution, state: 'confirmed', project: project, reward: reward_03)
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

  describe '#pending_contributions_reached_the_goal?' do
    let(:project) { create(:project, goal: 200) }

    before { project.stub(:pleged) { 100 } }

    subject { project.pending_contributions_reached_the_goal? }

    context 'when reached the goal with pending contributions' do
      before { 2.times { create(:contribution, project: project, value: 120, state: 'waiting_confirmation') } }

      it { should be_true }
    end

    context 'when dont reached the goal with pending contributions' do
      before { 2.times { create(:contribution, project: project, value: 30, state: 'waiting_confirmation') } }

      it { should be_false }
    end
  end

  describe "#new_draft_recipient" do
    subject { project.new_draft_recipient }
    before do
      CatarseSettings[:email_projects] = 'admin_projects@foor.bar'
      @user = create(:user, email: CatarseSettings[:email_projects])
    end
    it{ should == @user }
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

  describe ".enabled_to_use_pagarme" do
    before do
      @project_01 = create(:project, permalink: 'a')
      @project_02 = create(:project, permalink: 'b')
      @project_03 = create(:project, permalink: 'c')

      CatarseSettings[:projects_enabled_to_use_pagarme] = 'a, c'
    end

    subject { Project.enabled_to_use_pagarme }

    it { should == [@project_01, @project_03]}
  end

  describe "#using_pagarme?" do
    let(:project) { create(:project, permalink: 'foo') }

    subject { project.using_pagarme? }

    context "when project is using pagarme" do
      before do
        CatarseSettings[:projects_enabled_to_use_pagarme] = 'foo'
      end

      it { should be_true }
    end

    context "when project is not using pagarme" do
      before do
        CatarseSettings[:projects_enabled_to_use_pagarme] = nil
      end

      it { should be_false }
    end
  end
end
