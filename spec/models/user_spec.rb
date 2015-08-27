require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user){ create(:user) }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:facebook_provider){ create :oauth_provider, name: 'facebook' }

  describe "associations" do
    it{ is_expected.to have_many(:payments).through(:contributions) }
    it{ is_expected.to have_many :contributions }
    it{ is_expected.to have_many :contribution_details }
    it{ is_expected.to have_many :projects }
    it{ is_expected.to have_many :published_projects }
    it{ is_expected.to have_many :notifications }
    it{ is_expected.to have_many :project_posts }
    it{ is_expected.to have_many :unsubscribes }
    it{ is_expected.to have_many :authorizations }
    it{ is_expected.to have_one :user_total }
    it{ is_expected.to have_one :bank_account }
    it{ is_expected.to belong_to :country }
  end

  describe "validations" do
    before{ user }
    it{ is_expected.to allow_value('foo@bar.com').for(:email) }
    it{ is_expected.not_to allow_value('foo').for(:email) }
    it{ is_expected.not_to allow_value('foo@bar').for(:email) }
    it{ is_expected.to validate_uniqueness_of(:email) }
  end

  describe ".to_send_category_notification" do
    let(:category) { create(:category) }
    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }

    before do
      create(:project, category: category, user: user)
      category.users << user_1
      category.users << user_2
      category.deliver_projects_of_week_notification
      category.users << user
    end

    subject { User.to_send_category_notification(category.id) }

    it { is_expected.to eq([user]) }

  end

  describe "#pending_refund_payments_projects" do
    let(:user) { create(:user) }
    let(:failed_project) { create(:project, state: 'online') }
    let(:invalid_payment) do
      c = create(:confirmed_contribution, project: failed_project, user: user)
      c.payments.update_all({
        gateway: 'Pagarme',
        payment_method: 'BoletoBancario'})
      c.payments.first
    end

    let(:valid_payment) do
      c = create(:pending_refund_contribution, project: failed_project, user: user)
      c.payments.update_all(gateway: 'Pagarme')
      c.payments.first
    end

    subject { user.pending_refund_payments_projects }

    before do
      invalid_payment
      valid_payment
      failed_project.update_column(:state, 'failed')
    end

    it { is_expected.to eq([failed_project]) }
  end

  describe "#pending_refund_payments" do
    let(:user) { create(:user) }
    let(:failed_project) { create(:project, state: 'online') }
    let(:invalid_payment) do
      c = create(:confirmed_contribution, project: failed_project, user: user)
      c.payments.update_all({
        gateway: 'Pagarme',
        payment_method: 'BoletoBancario'})
      c.payments.first
    end
    let(:in_queue_payment) do
      c = create(:confirmed_contribution, project: failed_project, user: user)
      c.payments.update_all({
        gateway: 'Pagarme',
        payment_method: 'BoletoBancario'})
      c.payments.first
    end
    let(:valid_payment) do
      c = create(:pending_refund_contribution, project: failed_project, user: user)
      c.payments.update_all(gateway: 'Pagarme')
      c.payments.first
    end

    subject { user.pending_refund_payments }

    before do
      invalid_payment
      valid_payment
      in_queue_payment.direct_refund
      failed_project.update_column(:state, 'failed')
    end

    it { is_expected.to eq([invalid_payment]) }
    it { expect(in_queue_payment.already_in_refund_queue?).to eq(true) }
  end

  describe ".find_active!" do
    it "should raise error when user is inactive" do
      @inactive_user = create(:user, deactivated_at: Time.now)
      expect(->{ User.find_active!(@inactive_user.id) }).to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should return user when active" do
      expect(User.find_active!(user.id)).to eq user
    end
  end

  describe ".active" do
    subject{ User.active }

    before do
      user
      create(:user, deactivated_at: Time.now)
    end

    it{ is_expected.to eq [user] }
  end

  describe ".has_credits" do
    subject{ User.has_credits }

    context "when he has credits in the user_total" do
      before do
        with_credit = create(:confirmed_contribution, project: failed_project)
        with_credit.payments.first.update_attributes({gateway: 'MoIP'})

        @user_with_credits = with_credit.user
        failed_project.update_attributes state: 'failed'
        payment = create(:confirmed_contribution, project: successful_project).payments.first
        payment.update_attributes({gateway: 'MoIP'})

        UserTotal.refresh_view
      end
      it{ is_expected.to eq([@user_with_credits]) }
    end

    context "when he has credits in the user_total but is checked with zero credits" do
      before do
        b = create(:confirmed_contribution, value: 100, project: failed_project)
        b.payments.first.update_attributes({gateway: 'MoIP'})
        failed_project.update_attributes state: 'failed'
        @u = b.user

        b = create(:confirmed_contribution, value: 100, project: successful_project)
        b.payments.first.update_attributes({gateway: 'MoIP'})
        @u.update_attributes(zero_credits: true)
        UserTotal.refresh_view
      end
      it{ is_expected.to eq([]) }
    end
  end

  describe ".has_not_used_credits_last_month" do
    subject{ User.has_not_used_credits_last_month }

    context "when he has used credits in the last month" do
      before do
        create(:contribution_with_credits)
      end
      it{ is_expected.to eq([]) }
    end

    context "when he has not used credits in the last month" do
      before do
        with_credits  = create(:confirmed_contribution, project: failed_project)
        with_credits.payments.first.update_attributes({gateway: 'MoIP'})
        @user_with_credits = with_credits.user
        failed_project.update_attributes state: 'failed'
        UserTotal.refresh_view
      end
      it{ is_expected.to eq([@user_with_credits]) }
    end
  end

  describe ".by_payer_email" do
    before do
      p = create(:payment_notification)
      contribution = p.contribution
      @u = contribution.user
      p.extra_data = {'payer_email' => 'foo@bar.com'}
      p.save!
      p = create(:payment_notification, contribution: contribution)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
      p = create(:payment_notification)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
    end
    subject{ User.by_payer_email 'foo@bar.com' }
    it{ is_expected.to eq([@u]) }
  end

  describe ".by_key" do
    before do
      @payment = create(:payment)
      @contribution = create(:contribution, payments: [@payment])
      @user = @contribution.user
      create(:contribution)
    end
    subject{ User.by_key @payment.key }
    it{ is_expected.to eq([@user]) }
  end

  describe ".by_id" do
    before do
      @u = create(:user)
      create(:user)
    end
    subject{ User.by_id @u.id }
    it{ is_expected.to eq([@u]) }
  end

  describe ".by_name" do
    before do
      @u = create(:user, name: 'Foo Bar')
      create(:user, name: 'Baz Qux')
    end
    subject{ User.by_name 'Bar' }
    it{ is_expected.to eq([@u]) }
  end

  describe ".by_email" do
    before do
      @u = create(:user, email: 'foo@bar.com')
      create(:user, email: 'another_email@bar.com')
    end
    subject{ User.by_email 'foo@bar' }
    it{ is_expected.to eq([@u]) }
  end

  describe ".who_contributed_project" do
    subject{ User.who_contributed_project(successful_project.id) }
    before do
      @contribution = create(:confirmed_contribution, project: successful_project)
      create(:confirmed_contribution, project: successful_project, user: @contribution.user)
      create(:pending_contribution, project: successful_project)
    end
    it{ is_expected.to eq([@contribution.user]) }
  end

  describe ".create" do
    subject do
      User.create! do |u|
        u.email = 'diogob@gmail.com'
        u.password = '123456'
        u.twitter = '@dbiazus'
        u.facebook_link = 'facebook.com/test'
      end
    end
    its(:twitter){ should == 'dbiazus' }
    its(:facebook_link){ should == 'http://facebook.com/test' }
  end

  describe "#fix_twitter_user" do
    context "when twitter is full link" do
      let(:user) { build(:user, twitter: "https://twitter.com/username") }
      before { user.fix_twitter_user }
      it { expect(user.twitter).to eq("username") }
    end

    context "when twitter is null" do
      let(:user) { build(:user, twitter: nil) }
      before { user.fix_twitter_user }
      it { expect(user.twitter).to eq(nil) }
    end

    context "when twitter is @username" do
      let(:user) { build(:user, twitter: "@username") }
      before { user.fix_twitter_user }
      it { expect(user.twitter).to eq("username") }
    end

    context "when twitter is username" do
      let(:user) { build(:user, twitter: "username") }
      before { user.fix_twitter_user }
      it { expect(user.twitter).to eq("username") }
    end
  end

  describe "#change_locale" do
    let(:user) { create(:user, locale: 'pt') }

    context "when user already has a locale" do
      before do
        expect(user).not_to receive(:update_attributes).with(locale: 'pt')
      end

      it { user.change_locale('pt') }
    end

    context "when locale is diff from the user locale" do
      before do
        expect(user).to receive(:update_attributes).with(locale: 'en')
      end

      it { user.change_locale('en') }
    end
  end

  describe "#notify" do
    before do
      user.notify(:heartbleed)
    end

    it "should create notification" do
      notification = UserNotification.last
      expect(notification.user).to eq user
      expect(notification.template_name).to eq 'heartbleed'
    end
  end

  describe "#reactivate" do
    before do
      user.deactivate
      user.reactivate
    end

    it "should set reatiactivate_token to nil" do
      expect(user.reactivate_token).to be_nil
    end

    it "should set deactivated_at to nil" do
      expect(user.deactivated_at).to be_nil
    end
  end

  describe "#deactivate" do
    before do
      @contribution = create(:contribution, user: user, anonymous: false)
      user.deactivate
    end

    it "should send user_deactivate notification" do
      expect(UserNotification.last.template_name).to eq 'user_deactivate'
    end

    it "should set all contributions as anonymous" do
      expect(@contribution.reload.anonymous).to eq(true)
    end

    it "should set reatiactivate_token" do
      expect(user.reactivate_token).to be_present
    end

    it "should set deactivated_at" do
      expect(user.deactivated_at).to be_present
    end
  end

  describe "#total_contributed_projects" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    subject { user.total_contributed_projects }

    before do
      create(:confirmed_contribution, user: user, project: project)
      create(:confirmed_contribution, user: user, project: project)
      create(:confirmed_contribution, user: user, project: project)
      create(:confirmed_contribution, user: user)
      user.reload
      UserTotal.refresh_view
    end

    it { is_expected.to eq(2)}
  end

  describe "#created_today?" do
    subject { user.created_today? }

    context "when user is created today and not sign in yet" do
      before do
        allow(user).to receive(:created_at).and_return(Time.zone.today)
        allow(user).to receive(:sign_in_count).and_return(0)
      end

      it { is_expected.to eq(true) }
    end

    context "when user is created today and already signed in more that once time" do
      before do
        allow(user).to receive(:created_at).and_return(Time.zone.today)
        allow(user).to receive(:sign_in_count).and_return(2)
      end

      it { is_expected.to eq(false) }
    end

    context "when user is created yesterday and not sign in yet" do
      before do
        allow(user).to receive(:created_at).and_return(Time.zone.yesterday)
        allow(user).to receive(:sign_in_count).and_return(1)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "#to_analytics_json" do
    subject{ user.to_analytics_json }
    it do
      is_expected.to eq({
        user_id: user.id,
        email: user.email,
        name: user.name,
        contributions: user.total_contributed_projects,
        projects: user.projects.count,
        published_projects: user.published_projects.count,
        created: user.created_at,
        has_online_project: user.has_online_project?,
        has_created_post: user.has_sent_notification?,
        last_login: user.last_sign_in_at,
        created_today: user.created_today?
      }.to_json)
    end
  end

  describe "#credits" do
    def create_contribution_with_payment user, project, value, credits, payment_state = 'paid'
      c = create(:confirmed_contribution, user_id: user.id, project: project)
      c.payments.first.update_attributes gateway: (credits ? 'Credits' : 'AnyButCredits'), value: value, state: payment_state
    end
    before do
      @u = create(:user)
      create_contribution_with_payment @u, successful_project, 100, false
      create_contribution_with_payment @u, unfinished_project, 100, false
      create_contribution_with_payment @u, failed_project, 200, false
      create_contribution_with_payment @u, successful_project, 100, true
      create_contribution_with_payment @u, unfinished_project, 50, true
      create_contribution_with_payment @u, failed_project, 100, true
      create_contribution_with_payment @u, failed_project, 200, false, 'pending_refund'
      create_contribution_with_payment @u, failed_project, 200, false, 'refunded'

      failed_project.update_attributes state: 'failed'
      successful_project.update_attributes state: 'successful'
      UserTotal.refresh_view
    end

    subject{ @u.credits }

    it{ is_expected.to eq(50.0) }
  end

  describe "#update_attributes" do
    context "when I try to update moip_login" do
      before do
        user.update_attributes moip_login: 'test'
      end
      it("should perform the update"){ expect(user.moip_login).to eq('test') }
    end
  end

  describe "#recommended_project" do
    subject{ user.recommended_projects }
    before do
      other_contribution = create(:confirmed_contribution)
      create(:confirmed_contribution, user: other_contribution.user, project: unfinished_project)
      create(:confirmed_contribution, user: user, project: other_contribution.project)
    end
    it{ is_expected.to eq([unfinished_project])}
  end

  describe "#project_unsubscribes" do
    subject{user.project_unsubscribes}
    before do
      @p1 = create(:project)
      create(:confirmed_contribution, user: user, project: @p1)
      @u1 = create(:unsubscribe, project_id: @p1.id, user_id: user.id )
    end
    it{ is_expected.to eq([@u1])}
  end

  describe "#contributed_projects" do
    subject{user.contributed_projects}
    before do
      @p1 = create(:project)
      create(:confirmed_contribution, user: user, project: @p1)
      create(:confirmed_contribution, user: user, project: @p1)
    end
    it{is_expected.to eq([@p1])}
  end

  describe "#failed_contributed_projects" do
    subject{user.failed_contributed_projects}
    before do
      @failed_project = create(:project, state: 'online')
      @online_project = create(:project, state: 'online')
      create(:confirmed_contribution, user: user, project: @failed_project)
      create(:confirmed_contribution, user: user, project: @online_project)
      @failed_project.update_columns state: 'failed'
    end
    it{is_expected.to eq([@failed_project])}
  end

  describe "#fix_facebook_link" do
    subject{ user.facebook_link }
    context "when user provides invalid url" do
      let(:user){ create(:user, facebook_link: 'facebook.com/foo') }
      it{ is_expected.to eq('http://facebook.com/foo') }
    end
    context "when user provides valid url" do
      let(:user){ create(:user, facebook_link: 'http://facebook.com/foo') }
      it{ is_expected.to eq('http://facebook.com/foo') }
    end
  end

  describe "#has_valid_contribution_for_project??" do
    let(:project) { create(:project) }
    subject { user.has_valid_contribution_for_project?(project.id) }

    context "when user has valid contributions for the project" do
      before do
        create(:confirmed_contribution, project: project, user: user)
      end

      it { is_expected.to eq(true) }
    end

    context "when user don't have valid contributions for the project" do
      before do
        create(:pending_contribution, project: project, user: user)
      end
      it { is_expected.to eq(false) }
    end
    context "when user don't have contributions for the project" do
      it { is_expected.to eq(false) }
    end
  end

  describe "#nullify_permalink" do
    subject{ user.permalink }
    context "when user provides blank permalink" do
      let(:user){ create(:user, permalink: '') }
      it{ is_expected.to eq(nil) }
    end
    context "when user provides permalink" do
      let(:user){ create(:user, permalink: 'foo') }
      it{ is_expected.to eq('foo') }
    end
  end

  describe "#made_any_contribution_for_this_project?" do
    let(:project) { create(:project) }
    subject { user.made_any_contribution_for_this_project?(project.id) }

    context "when user have contributions for the project" do
      before do
        create(:confirmed_contribution, project: project, user: user)
      end

      it { is_expected.to eq(true) }
    end

    context "when user don't have contributions for the project" do
      it { is_expected.to eq(false) }
    end
  end

  describe "#has_sent_notification?" do
    subject{ user.has_sent_notification? }
    let(:user) { create(:user) }

    context "when user has sent notifications" do
      let(:project) { create(:project, user: user, state: 'online') }
      before do
        create(:project_post, user: user, project: project )
      end

      it{ is_expected.to eq(true) }
    end

    context "when user has not sent notifications" do
      before do
        create(:project, user: user, state: 'online')
      end

      it{ is_expected.to eq(false) }
    end

    context "when user has no project" do
      it{ is_expected.to eq(false) }
    end
  end

  describe "#has_online_project?" do
    subject{ user.has_online_project? }
    let(:user) { create(:user) }

    context "when user has project online" do
      before do
        create(:project, user: user, state: 'online')
      end

      it{ is_expected.to eq(true) }
    end

    context "when user has project not online" do
      before do
        create(:project, user: user, state: 'draft')
      end

      it{ is_expected.to eq(false) }
    end

    context "when user has no project" do
      it{ is_expected.to eq(false) }
    end
  end

  describe "#following_this_category?" do
    let(:category) { create(:category) }
    let(:category_extra) { create(:category) }
    let(:user) { create(:user) }
    subject { user.following_this_category?(category.id)}

    context "when is following the category" do
      before do
        user.categories << category
      end

      it { is_expected.to eq(true) }
    end

    context "when not following the category" do
      before do
        user.categories << category_extra
      end

      it { is_expected.to eq(false) }
    end

    context "when not following any category" do
      it { is_expected.to eq(false) }
    end
  end

  describe "PostgREST users synchronization" do
    it "should delete api user on user destroy" do
      user = create(:user)
      user.bank_account.destroy!
      User.connection.select_all("DELETE FROM public.users WHERE email = '#{user.email}'")
      expect(User.connection.select_all("SELECT * FROM postgrest.auth WHERE id = '#{user.email}'").count).to eq 0
    end

    it "should update api user on user update" do
      user = create(:user)
      user.email = 'foo@bar.com'
      user.admin = true
      user.save!
      api_user = User.connection.select_all("SELECT * FROM postgrest.auth WHERE id = '#{user.id}'")[0]
      expect(api_user["id"]).to eq user.id.to_s
      expect(api_user["rolname"]).to eq 'admin'
      expect(api_user["pass"].size).to eq 60
    end

    it "should create api user on user creation" do
      user = create(:user)
      api_user = User.connection.select_all("SELECT * FROM postgrest.auth WHERE id = '#{user.id}'")[0]
      expect(api_user["id"]).to eq user.id.to_s
      expect(api_user["rolname"]).to eq 'web_user'
      expect(api_user["pass"].size).to eq 60
    end
  end
end
