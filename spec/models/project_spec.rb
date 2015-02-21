# coding: utf-8
require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project){ build(:project, goal: 3000) }
  let(:user){ create(:user) }

  describe "associations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :category }
    it{ is_expected.to have_many :contributions }
    it{ is_expected.to have_one  :project_total }
    it{ is_expected.to have_many :rewards }
    it{ is_expected.to have_many :posts }
    it{ is_expected.to have_many :notifications }
  end

  describe "validations" do
    %w[name user category permalink].each do |field|
      it{ is_expected.to validate_presence_of field }
    end
    it{ is_expected.to validate_numericality_of(:goal) }
    it{ is_expected.to allow_value(10).for(:goal) }
    it{ is_expected.not_to allow_value(8).for(:goal) }
    it{ is_expected.to ensure_length_of(:headline).is_at_most(140) }
    it{ is_expected.to allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.not_to allow_value('http://www.foo.bar').for(:video_url) }
    it{ is_expected.to allow_value('testproject').for(:permalink) }
    it{ is_expected.to allow_value('test-project').for(:permalink) }
    it{ is_expected.to allow_value(1).for(:online_days) }
    it{ is_expected.not_to allow_value(0).for(:online_days) }
    it{ is_expected.not_to allow_value(61).for(:online_days) }
    it{ is_expected.not_to allow_value('users').for(:permalink) }
    it{ is_expected.not_to allow_value('agua.sp.01').for(:permalink) }
  end

  describe ".of_current_week" do
    subject { Project.of_current_week }
    before do
      3.times { create(:project, state: 'online', online_date: DateTime.now) }
      3.times { create(:project, state: 'draft', online_date: 3.days.ago) }
      3.times { create(:project, state: 'successful', online_date: 6.days.ago) }
      5.times { create(:project, state: 'online', online_date: 8.days.ago) }
      5.times { create(:project, state: 'online', online_date: 2.weeks.ago) }
      build(:project, state: 'in_analysis', online_date: 3.days.from_now).save(validate: false)
    end

    it "should return a collection with projects of current week" do
      is_expected.to have(10).itens
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

      it { is_expected.to have(2).items }
      it { expect(subject.include?(project_02)).to eq(false) }
    end

    context "when does not have any confirmed contribution today" do
      before do
        create(:contribution, state: 'confirmed', project: project_01, confirmed_at: 1.days.ago )
        create(:contribution, state: 'confirmed', project: project_02, confirmed_at: 2.days.ago )
        create(:contribution, state: 'confirmed', project: project_03, confirmed_at: 5.days.ago )
      end

      it { is_expected.to have(0).items }
    end
  end

  describe ".visible" do
    before do
      [:draft, :rejected, :deleted].each do |state|
        create(:project, state: state)
      end
      build(:project, state: :in_analysis).save(validate: false)
      @project = create(:project, state: :online)
    end
    subject{ Project.visible }
    it{ is_expected.to eq([@project]) }
  end

  describe '.state_names' do
    let(:states) { [:draft, :rejected, :approved, :online, :successful, :waiting_funds, :failed, :in_analysis] }

    subject { Project.state_names }

    it { is_expected.to eq(states) }
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

    it { is_expected.to have(3).itens }
  end

  describe ".by_permalink" do
    context "when project is deleted" do
      before do
        @p = create(:project, permalink: 'foo', state: 'deleted')
        create(:project, permalink: 'bar')
      end
      subject{ Project.by_permalink('foo') }
      it{ is_expected.to eq([]) }
    end
    context "when project is not deleted" do
      before do
        @p = create(:project, permalink: 'foo')
        create(:project, permalink: 'bar')
      end
      subject{ Project.by_permalink('foo') }
      it{ is_expected.to eq([@p]) }
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

    it { is_expected.to have(2).itens }
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
        @project_01 = create(:project, goal: 6000, state: 'approved')
      end

      it{ is_expected.not_to allow_value(nil).for(:video_url) }
    end

    context 'when goal is below minimum' do
      subject { @project_02 }

      before do
        CatarseSettings[:minumum_goal_for_video] = 5000
        @project_02 = create(:project, goal: 4000)
      end

      it{ is_expected.to allow_value(nil).for(:video_url) }
    end

    context 'when goal is minimum' do
      subject { @project_03 }

      before do
        @project_03 = build(:project, goal: 5000, state: 'approved', video_url: nil)
      end

      it{ is_expected.not_to allow_value(nil).for(:video_url) }
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

    it { is_expected.to eq('lorem') }
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

    it { is_expected.to eq([@project_01]) }
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

    it { is_expected.to eq([@project_01, @project_02]) }
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

    it { is_expected.to eq([project_02, project_01]) }
  end

  describe '.to_finish' do
    before do
      expect(Project).to receive(:expired).and_call_original
      expect(Project).to receive(:with_states).with(['online', 'waiting_funds']).and_call_original
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
    it{ is_expected.to eq([@p]) }
  end

  describe ".not_expired" do
    before do
      @p = create(:project, online_days: 1)
      create(:project, online_days: 1, online_date: Time.now - 2.days)
    end
    subject{ Project.not_expired }
    it{ is_expected.to eq([@p]) }
  end

  describe ".expiring" do
    before do
      @p = create(:project, online_date: Time.now, online_days: 13)
      create(:project, online_date: Time.now, online_days: 1, online_date: Time.now - 2.days)
    end
    subject{ Project.expiring }
    it{ is_expected.to eq([@p]) }
  end

  describe ".not_expiring" do
    before do
      @p = create(:project, online_days: 15)
      create(:project, online_days: 1, online_date: Time.now - 2.days)
    end
    subject{ Project.not_expiring }
    it{ is_expected.to eq([@p]) }
  end

  describe ".recent" do
    before do
      @p = create(:project, online_date: (Time.now - 4.days))
      create(:project, online_date: (Time.now - 15.days))
    end
    subject{ Project.recent }
    it{ is_expected.to eq([@p]) }
  end

  describe '#reached_goal?' do
    let(:project) { create(:project, goal: 3000) }
    subject { project.reached_goal? }

    context 'when sum of all contributions hit the goal' do
      before do
        create(:contribution, value: 4000, project: project)
      end
      it { is_expected.to eq(true) }
    end

    context "when sum of all contributions don't hit the goal" do
      it { is_expected.to eq(false) }
    end
  end

  describe '#in_time_to_wait?' do
    let(:contribution) { create(:contribution, state: 'waiting_confirmation') }
    subject { contribution.project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { is_expected.to eq(true) }
    end

    context 'when project expiration time is not more on time to wait' do
      let(:contribution) { create(:contribution, created_at: 1.week.ago) }
      it {is_expected.to eq(false)}
    end
  end

  describe "#pg_search" do
    before { @p = create(:project, name: 'foo') }
    context "when project exists" do
      subject{ [Project.pg_search('foo'), Project.pg_search('fóõ')] }
      it{ is_expected.to eq([[@p],[@p]]) }
    end
    context "when project is not found" do
      subject{ Project.pg_search('lorem') }
      it{ is_expected.to eq([]) }
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
    it{ is_expected.to eq(@confirmed.value + @waiting.value) }
  end

  describe "#pledged" do
    subject{ project.pledged }
    context "when project_total is nil" do
      before do
        allow(project).to receive(:project_total).and_return(nil)
      end
      it{ is_expected.to eq(0) }
    end
    context "when project_total exists" do
      before do
        project_total = double()
        allow(project_total).to receive(:pledged).and_return(10.0)
        allow(project).to receive(:project_total).and_return(project_total)
      end
      it{ is_expected.to eq(10.0) }
    end
  end

  describe "#total_payment_service_fee" do
    subject { project.total_payment_service_fee }

    context "when project_total is nil" do
      before { allow(project).to receive(:project_total).and_return(nil) }
      it { is_expected.to eq(0) }
    end

    context "when project_total exists" do
      before do
        project_total = double()
        allow(project_total).to receive(:total_payment_service_fee).and_return(4.0)
        allow(project).to receive(:project_total).and_return(project_total)
      end

      it { is_expected.to eq(4.0) }
    end
  end

  describe "#total_contributions" do
    subject{ project.total_contributions }
    context "when project_total is nil" do
      before do
        allow(project).to receive(:project_total).and_return(nil)
      end
      it{ is_expected.to eq(0) }
    end
    context "when project_total exists" do
      before do
        project_total = double()
        allow(project_total).to receive(:total_contributions).and_return(1)
        allow(project).to receive(:project_total).and_return(project_total)
      end
      it{ is_expected.to eq(1) }
    end
  end

  describe "#expired?" do
    subject{ project.expired? }

    context "when online_date is nil" do
      let(:project){ Project.new online_date: nil, online_days: 0 }
      it{ is_expected.to eq(nil) }
    end

    context "when expires_at is in the future" do
      let(:project){ Project.new online_date: 2.days.from_now, online_days: 0 }
      it{ is_expected.to eq(nil) }
    end

    context "when expires_at is in the past" do
      let(:project){ build(:project, online_date: 3.days.ago, online_days: 1) }
      before{project.save!}
      it{ is_expected.to eq(true) }
    end
  end

  describe "#expires_at" do
    subject{ project.expires_at }
    context "when we do not have an online_date" do
      let(:project){ build(:project, online_date: nil, online_days: 1) }
      it{ is_expected.to be_nil }
    end
    context "when we have an online_date" do
      let(:project){ create(:project, online_date: Time.zone.now, online_days: 1)}
      before{project.save!}
      it{ expect(subject.in_time_zone('Brasilia').to_s(:short)).to eq(Time.zone.tomorrow.end_of_day.to_s(:short)) }
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
    it { is_expected.to eq([reward_01, reward_03]) }
  end

  describe "#new_draft_recipient" do
    subject { project.new_draft_recipient }
    before do
      CatarseSettings[:email_projects] = 'admin_projects@foor.bar'
      @user = create(:user, email: CatarseSettings[:email_projects])
    end
    it{ is_expected.to eq(@user) }
  end

  describe ".enabled_to_use_pagarme" do
    before do
      @project_01 = create(:project, permalink: 'a', online_date: '2014-10-9'.to_date)
      @project_02 = create(:project, permalink: 'b', online_date: '2014-10-9'.to_date)
      @project_03 = create(:project, permalink: 'c', online_date: '2014-10-9'.to_date)
      @project_04 = create(:project, online_date: '2014-11-11'.to_date)

      CatarseSettings[:projects_enabled_to_use_pagarme] = 'a, c'
    end

    subject { Project.enabled_to_use_pagarme }

    it { is_expected.to match_array([@project_01, @project_03, @project_04])}
  end

  describe "#using_pagarme?" do
    let(:project) { create(:project, permalink: 'foo', online_date: '2014-10-01'.to_date) }

    subject { project.using_pagarme? }

    context "when project is using pagarme" do
      before do
        CatarseSettings[:projects_enabled_to_use_pagarme] = 'foo'
      end

      it { is_expected.to be_truthy }
    end

    context "when project is online_date >= 10/11" do
      before do
        project.update_attribute(:online_date, '2014-11-11'.to_date)
      end

      subject { project.using_pagarme? }
      it { is_expected.to be_truthy }
    end

    context "when project is not using pagarme" do
      before do
        CatarseSettings[:projects_enabled_to_use_pagarme] = nil
      end

      it { is_expected.to be_falsey }
    end
  end
end
