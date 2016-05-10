# coding: utf-8
require 'rails_helper'

def all_machine_states
  %w(
    draft rejected online successful waiting_funds
    deleted in_analysis approved failed
  )
end

RSpec.describe Project, type: :model do
  let(:project){ create(:project, goal: 3000) }
  let(:user){ create(:user) }

  describe "associations" do
    it{ is_expected.to belong_to :origin }
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :category }
    it{ is_expected.to have_many :contributions }
    it{ is_expected.to have_many :tags }
    it{ is_expected.to have_many :contribution_details }
    it{ is_expected.to have_many(:payments).through(:contributions) }
    it{ is_expected.to have_one  :project_total }
    it{ is_expected.to have_many :rewards }
    it{ is_expected.to have_many :posts }
    it{ is_expected.to have_many :notifications }
    it{ is_expected.to have_many :project_transitions }
  end

  describe "validations" do
    %w[name user category].each do |field|
      it{ is_expected.to validate_presence_of field }
    end
    it{ is_expected.to validate_numericality_of(:goal) }
    it{ is_expected.to allow_value(10).for(:goal) }
    it{ is_expected.not_to allow_value(8).for(:goal) }
    it{ is_expected.to validate_length_of(:headline).is_at_most(Project::HEADLINE_MAXLENGTH) }
    it{ is_expected.to allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ is_expected.to allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.to allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ is_expected.not_to allow_value('http://www.foo.bar').for(:video_url) }
    it{ is_expected.to allow_value('testproject').for(:permalink) }
    it{ is_expected.to allow_value('test-project').for(:permalink) }
    it{ is_expected.to allow_value(2).for(:online_days) }
    it{ is_expected.not_to allow_value(0).for(:online_days) }
    it{ is_expected.not_to allow_value(1).for(:online_days) }
    it{ is_expected.not_to allow_value(61).for(:online_days) }
    it{ is_expected.not_to allow_value('users').for(:permalink) }
    it{ is_expected.not_to allow_value('agua.sp.01').for(:permalink) }
  end

  context "state check methods" do
    all_machine_states.each do |st|
      describe "##{st}? when project state is #{st}" do
        before { project.state = st }
        subject { project.send("#{st}?") }
        it { is_expected.to eq true }
      end

      describe "##{st}? when project state is not #{st}" do
        before { project.state = all_machine_states.reject { |x| x == st }.sample }
        subject { project.send("#{st}?") }
        it { is_expected.to eq false }
      end
    end
  end

  describe '#has_account_error?' do
    let(:project_account) { create(:project_account) }
    let(:project) { project_account.project }

    subject { project.has_account_error? }

    context 'when project account does not created' do
      let(:project_account) { build(:project_account) }
      it { is_expected.to eq(false) }
    end

    context 'when project account is fine' do
      before do
        create(:project_account_error, project_account: project_account, solved: true)
      end
      it { is_expected.to eq(false) }
    end

    context 'when have unsolved error on project account' do
      before do
        create(:project_account_error, project_account: project_account)
      end
      it { is_expected.to eq(true) }
    end
  end

  describe ".with_state" do
    let(:project_state) { 'online' }
    subject { Project.with_state(project_state).count }

    context "when has online projects" do
      before do
        4.times { create(:project, state: 'online') }
      end

      it {is_expected.to eq(4) }
    end

    context "when not have online projects" do
      it { is_expected.to eq(0) }
    end

    context "when state is a list" do
      let(:project_state) { ['online', 'failed'] }
      before do
        4.times { create(:project, state: 'online') }
        2.times { create(:project, state: 'failed') }
      end

      it {is_expected.to eq(6) }
    end

    context "when is flexible project online" do
      let(:project_state) { 'online' }
      before do
        create(:flexible_project, state: 'online', project: create(:project, state: 'draft'))
      end

      it {is_expected.to eq(1)}
    end
  end

  describe ".without_state" do
    let(:project_state) { 'online' }
    subject { Project.without_state(project_state).count }

    context "when has online and failed projects" do
      before do
        4.times { create(:project, state: 'online') }
        2.times { create(:project, state: 'failed') }
      end

      it { is_expected.to eq(2) }
    end

    context "when not have any projects" do
      it { is_expected.to eq(0) }
    end

    context "when is flexible project online" do
      let(:project_state) { 'draft' }
      before do
        create(:flexible_project, state: 'online', project: create(:project, state: 'draft'))
      end

      it {is_expected.to eq(1)}
    end

  end


  describe "#state_machine" do
    let!(:project) { create(:project) }

    subject { project.state_machine }

    it { is_expected.to be_an_instance_of(AonProjectMachine) }
  end

  describe "name validation" do
    context "when project is not published" do
      let(:project) { create(:project, state: 'draft') }

      it "should be validate size of name when project is in analysis" do
        project.state = 'in_analysis'
        project.name = 'l'*100
        expect(project.valid?).to eq(false)

        project.name = 'l'*50
        expect(project.valid?).to eq(true)
      end
    end
  end

  describe "online_days" do
    context "when we have valid data" do
      before do
        create(:project, state: 'online', online_days: 60)
      end

      it{ is_expected.not_to allow_value(61).for(:online_days) }
    end

    context "when we have data set manually in the db" do
      let(:project) {create_project({state: 'online', online_days: 60}, {to_state: 'online'})}
      subject { project }
      before do
        project.update_attributes online_days: 61
        project.save(validate: false)
      end

      it{ is_expected.to allow_value(62).for(:online_days) }

      it "should update expires_at" do
        expect(project.expires_at).to eq (project.online_at.in_time_zone + project.online_days.days).end_of_day
      end
    end

  end

  describe "#published?" do
    subject { project.published? }

    context "when project is failed" do
      let!(:project) { create(:project, state: 'failed') }
      it { is_expected.to eq(true) }
    end

    context "when project is online" do
      let!(:project) { create(:project, state: 'online') }
      it { is_expected.to eq(true) }
    end

    context "when project in approved" do
      let!(:project) { create(:project, state: 'approved') }
      it { is_expected.to eq(false) }
    end

    context "when project in draft" do
      let!(:project) { create(:project, state: 'draft') }
      it { is_expected.to eq(false) }
    end
  end

  describe ".of_current_week" do
    subject { Project.of_current_week }
    before do
      3.times { create_project({state: 'online'}, {to_state: 'online'}) }
      3.times { create_project({state: 'draft'}, {}) }
      3.times { create_project({state: 'successful'}, [{to_state: 'online', created_at: 5.days.ago, most_recent: false}, {to_state: 'successful', created_at: 1.days.ago}]) }
      5.times { create_project({state: 'online'}, {to_state: 'online', created_at: 8.days.ago})}
      5.times { create_project({state: 'online'}, {to_state: 'online', created_at: 2.weeks.ago}) }
    end

    it "should return a collection with projects of current week" do
      is_expected.to have(6).itens
    end
  end

  describe ".with_contributions_confirmed_last_day" do
    let(:project_01) { create(:project, state: 'online') }
    let(:project_02) { create(:project, state: 'online') }

    subject { Project.with_contributions_confirmed_last_day }

    context "when have confirmed contributions last day" do
      before do
        @confirmed_today = create(:confirmed_contribution, project: project_01)
        @confirmed_today.payments.first.update_attributes paid_at: Time.now
        old = create(:confirmed_contribution, project: project_02)
        old.payments.first.update_attributes paid_at: 2.days.ago
      end

      it { is_expected.to eq [project_01] }
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
    let(:states) { [:draft, :rejected, :approved, :online, :successful, :waiting_funds, :failed, :deleted, :in_analysis] }
  
    subject { Project.state_names }
  
    it { is_expected.to match_array(states) }
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

      create(:confirmed_contribution, value: 10, project: @project_01)
      create(:confirmed_contribution, value: 10, project: @project_01)
      create(:confirmed_contribution, value: 30, project: @project_02)
      create(:confirmed_contribution, value: 10, project: @project_03)
    end

    it { is_expected.to have(2).itens }
  end

  describe '.by_goal' do
    subject { Project.by_goal(200) }

    before do
      @project_01 = create(:project, goal: 100)
      @project_02 = create(:project, goal: 200)

    end

    it { is_expected.to eq [@project_02] }
  end

  describe '.by_online_date' do
    subject { Project.by_online_date(Time.current.to_date.to_s) }

    before do
      @project_01 = create_project({state: 'online'}, {to_state: 'online'})
      @project_02 = create_project({state: 'online'}, {created_at: 2.weeks.ago, to_state: 'online'})

    end

    it { is_expected.to eq [@project_01] }
  end

  describe '.by_expires_at' do
    subject { Project.by_expires_at('10/10/2013') }

    before do
      @project_01 = create_project({state: 'online', online_days: 2}, {to_state: 'online', created_at: '2013-10-09'.to_date.in_time_zone})
      @project_02 = create_project({state: 'online', online_days: 2}, {created_at: '2013-10-08'.to_date.in_time_zone, to_state: 'online'})
    end

    it { is_expected.to eq [@project_02] }
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
    let(:start_at) { 1.day.ago.strftime('%d/%m/%Y') }
    let(:ends_at) { 3.days.from_now.strftime('%d/%m/%Y') }
    subject { Project.between_expires_at(start_at, ends_at).order("id desc") }

    let!(:project_01) { create_project({state: 'online', online_days: 2}, {to_state: 'online', created_at: Time.current}) }
    let!(:project_02) { create_project({state: 'online', online_days: 2}, {to_state: 'online', created_at: 1.day.from_now}) }
    let!(:project_03) { create_project({state: 'online', online_days: 2}, {to_state: 'online', created_at: 3.days.from_now}) }

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
      @p = create_project({online_days: 2, state: 'online'}, {to_state: 'online', created_at: 3.days.ago})
      create_project({online_days: 2, state: 'online'}, {to_state: 'online'})
    end
    subject{ Project.expired}
    it{ is_expected.to eq([@p]) }
  end

  describe ".not_expired" do
    before do
      @p = create_project({online_days: 2, state: 'online'}, {to_state: 'online'})
      create_project({online_days: 2, state: 'online'}, {to_state: 'online', created_at: 3.days.ago})
    end
    subject{ Project.not_expired }
    it{ is_expected.to eq([@p]) }
  end

  describe ".expiring" do
    before do
      @p = create_project({online_days: 13, state: 'online'}, {to_state: 'online'})
      create_project({online_days: 2, state: 'online'}, {to_state: 'online', created_at: 3.days.ago})
    end
    subject{ Project.expiring }
    it{ is_expected.to eq([@p]) }
  end

  describe ".not_expiring" do
    before do
      @p = create_project({online_days: 15, state: 'online'}, {to_state: 'online'})
      create_project({online_days: 2, state: 'online'}, {to_state: 'online', created_at: 3.days.ago})
    end
    subject{ Project.not_expiring }
    it{ is_expected.to eq([@p]) }
  end

  describe ".recent" do
    before do
      @p = create_project({state: 'online'}, {to_state: 'online', created_at: 4.days.ago})
      create_project({state: 'online'}, {to_state: 'online', created_at: 15.days.ago})
    end
    subject{ Project.recent }
    it{ is_expected.to eq([@p]) }
  end

  describe '#reached_goal?' do
    let(:project) { create(:project, goal: 3000) }
    subject { project.reached_goal? }

    context 'when sum of all contributions hit the goal' do
      before do
        create(:confirmed_contribution, value: 4000, project: project)
      end
      it { is_expected.to eq(true) }
    end

    context "when sum of all contributions don't hit the goal" do
      it { is_expected.to eq(false) }
    end

    context 'when sum of was_confirmed contribution hit the goal but paid sum only dont get it' do
      before do
        create(:confirmed_contribution, value: 2000, project: project)
        create(:refunded_contribution, value: 3000, project: project)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe '#in_time_to_wait?' do
    let(:contribution) { create(:pending_contribution) }
    subject { contribution.project.in_time_to_wait? }

    context 'when project has pending contributions' do
      it { is_expected.to eq(true) }
    end

    context 'when project has pending contributions older than 1 week' do
      let(:contribution) { create(:pending_contribution) }
      before do
        contribution.payments.update_all created_at: Time.now - 1.week
      end
      it { is_expected.to eq(false) }
    end

    context 'when project has no pending contributions' do
      let(:contribution) { create(:contribution) }
      it {is_expected.to eq(false)}
    end
  end

  describe "#search_tsearch" do
    subject{ Project.search_tsearch 'críptõrave' }

    before do
      @p = create(:project, name: 'criptorave')
      create(:project, name: 'nyan cat')
    end

    it{ is_expected.to match_array([@p]) }
  end

  describe "#search_trm" do
    subject{ Project.search_trm('críptõ') }

    before do
      @p = create(:project, name: 'criptorave')
      create(:project, name: 'nyan cat')
    end

    it{ is_expected.to match_array([@p]) }
  end

  describe "#pg_search" do
    subject{ Project.pg_search('críptõ') }
    let(:tsearch_return) { [] }

    before do
      allow(Project).to receive(:search_tsearch).and_return(tsearch_return)
      allow(Project).to receive(:search_trm).and_return(['trm'])
    end

    context "when tsearch is not empty" do
      let(:tsearch_return) { ["tsearch"] }
      it { is_expected.to match_array(tsearch_return) }
    end

    context "when tsearch is empty" do
      it { is_expected.to match_array(['trm']) }
    end
  end

  describe "pledged methods" do
    let(:project) { create(:project, state: 'online', goal: 100) }
    let!(:confirmed_contribution) { create(:confirmed_contribution, project: project, value: 10) }
    let!(:pending_contribution) { create(:pending_contribution, project: project, value: 10) }
    let!(:refunded_contribution) { create(:refunded_contribution, project: project, value: 10) }
    let!(:pending_refund_contribution) { create(:pending_refund_contribution, project: project, value: 10) }

    describe "#pledged" do
      subject{ project.pledged }

      context "when project_total is nil" do
        before do
          allow(project).to receive(:project_total).and_return(nil)
        end
        it{ is_expected.to eq(0) }
      end

      context "when project_total exists" do
        it "should return the sum of all payments that was_confirmed" do
          is_expected.to eq(30.0)
        end
      end
    end

    describe "#paid_pledged" do
      subject { project.paid_pledged }

      it "should return the sum of all payments that is_confirmed" do
        is_expected.to eq(10)
      end
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

    context "when is a builded project" do
      let(:project){ Project.new online_days: 0 }
      it{ is_expected.to eq(nil) }
    end

    context "when expires_at is in the future" do
      let(:project){ create_project({online_days: 3}, {to_state: 'online'}) }
      it{ is_expected.to eq(false) }
    end

    context "when expires_at is in the past" do
      let(:project){ create_project({online_days: 3}, {to_state: 'online', created_at: 5.days.ago}) }
      it{ is_expected.to eq(true) }
    end
  end

  describe '#selected_rewards' do
    let(:project){ create(:project) }
    let(:reward_01) { create(:reward, project: project) }
    let(:reward_02) { create(:reward, project: project) }
    let(:reward_03) { create(:reward, project: project) }

    before do
      create(:confirmed_contribution, project: project, reward: reward_01)
      create(:confirmed_contribution, project: project, reward: reward_03)
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

  describe "#to_analytics_json" do
    subject{ project.to_analytics_json }
    it do
      is_expected.to eq({
        id: project.id,
        permalink: project.permalink,
        total_contributions: project.total_contributions,
        pledged: project.pledged,
        project_state: project.state,
        category: project.category.name_pt,
        project_goal: project.goal,
        project_online_date: project.online_at,
        project_expires_at: project.expires_at,
        project_address_city: project.account.try(:address_city),
        project_address_state: project.account.try(:address_state),
        account_entity_type: project.account.try(:entity_type)
      }.to_json)
    end
  end

end
