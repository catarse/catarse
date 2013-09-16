require 'spec_helper'

describe User do
  let(:user){ create(:user) }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:notification_type){ create(:notification_type, name: 'updates') }
  let(:facebook_provider){ create :oauth_provider, name: 'facebook' }

  describe "associations" do
    it{ should have_many :backs }
    it{ should have_many :projects }
    it{ should have_many :notifications }
    it{ should have_many :updates }
    it{ should have_many :unsubscribes }
    it{ should have_many :authorizations }
    it{ should have_many(:oauth_providers).through(:authorizations) }
    it{ should have_one :user_total }
    it{ should have_and_belong_to_many :channels }
    it{ should have_and_belong_to_many :subscriptions }
  end

  describe "validations" do
    before{ user }
    it{ should allow_value('foo@bar.com').for(:email) }
    it{ should_not allow_value('foo').for(:email) }
    it{ should_not allow_value('foo@bar').for(:email) }
    it{ should allow_value('a'.center(139)).for(:bio) }
    it{ should allow_value('a'.center(140)).for(:bio) }
    it{ should_not allow_value('a'.center(141)).for(:bio) }
    it{ should validate_uniqueness_of(:email) }
  end

  describe ".has_credits" do
    subject{ User.has_credits }

    context "when he has credits in the user_total" do
      before do
        b = create(:backer, state: 'confirmed', value: 100, project: failed_project)
        failed_project.update_attributes state: 'failed'
        @u = b.user
        b = create(:backer, state: 'confirmed', value: 100, project: successful_project)
      end
      it{ should == [@u] }
    end
  end

  describe ".has_not_used_credits_last_month" do
    subject{ User.has_not_used_credits_last_month }

    context "when he has used credits in the last month" do
      before do
        b = create(:backer, state: 'confirmed', value: 100, credits: true)
        @u = b.user
      end
      it{ should == [] }
    end
    context "when he has not used credits in the last month" do
      before do
        b = create(:backer, state: 'confirmed', value: 100, project: failed_project)
        failed_project.update_attributes state: 'failed'
        @u = b.user
      end
      it{ should == [@u] }
    end
  end

  describe ".by_payer_email" do
    before do
      p = create(:payment_notification)
      backer = p.backer
      @u = backer.user
      p.extra_data = {'payer_email' => 'foo@bar.com'}
      p.save!
      p = create(:payment_notification, backer: backer)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
      p = create(:payment_notification)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
    end
    subject{ User.by_payer_email 'foo@bar.com' }
    it{ should == [@u] }
  end

  describe ".by_key" do
    before do
      b = create(:backer)
      @u = b.user
      b.key = 'abc'
      b.save!
      b = create(:backer, user: @u)
      b.key = 'abcde'
      b.save!
      b = create(:backer)
      b.key = 'def'
      b.save!
    end
    subject{ User.by_key 'abc' }
    it{ should == [@u] }
  end

  describe ".by_id" do
    before do
      @u = create(:user)
      create(:user)
    end
    subject{ User.by_id @u.id }
    it{ should == [@u] }
  end

  describe ".by_name" do
    before do
      @u = create(:user, name: 'Foo Bar')
      create(:user, name: 'Baz Qux')
    end
    subject{ User.by_name 'Bar' }
    it{ should == [@u] }
  end

  describe ".by_email" do
    before do
      @u = create(:user, email: 'foo@bar.com')
      create(:user, email: 'another_email@bar.com')
    end
    subject{ User.by_email 'foo@bar' }
    it{ should == [@u] }
  end

  describe ".who_backed_project" do
    subject{ User.who_backed_project(successful_project.id) }
    before do
      @backer = create(:backer, state: 'confirmed', project: successful_project)
      create(:backer, state: 'confirmed', project: successful_project, user: @backer.user)
      create(:backer, state: 'pending', project: successful_project)
    end
    it{ should == [@backer.user] }
  end

  describe ".backer_totals" do
    before do
      create(:backer, state: 'confirmed', value: 100, credits: false, project: successful_project)
      create(:backer, state: 'confirmed', value: 50, credits: false, project: successful_project)
      user = create(:backer, state: 'confirmed', value: 25, project: failed_project).user
      failed_project.update_attributes state: 'failed'
      successful_project.update_attributes state: 'successful'
      user.save!
      @u = create(:user)
    end

    context "when we call upon user without backs" do
      subject{ User.where(id: @u.id).backer_totals }
      it{ should == {users: 0.0, backers: 0.0, backed: 0.0, credits: 0.0} }
    end

    context "when we call without scopes" do
      subject{ User.backer_totals }
      it{ should == {users: 3.0, backers: 3.0, backed: 175.0, credits: 25.0} }
    end

    context "when we call with scopes" do
      subject{ User.has_credits.backer_totals }
      it{ should == {users: 1.0, backers: 1.0, backed: 25.0, credits: 25.0} }
    end
  end

  describe ".create_with_omniauth" do
    let(:auth)  do {
        'provider' => "twitter",
        'uid' => "foobar",
        'info' => {
          'name' => "Foo bar",
          'email' => 'another_email@anotherdomain.com',
          'nickname' => "foobar",
          'description' => "Foo bar's bio".ljust(200),
          'image' => "image.png"
        }
      }
    end
    let(:created_user){ User.create_with_omniauth(auth) }
    let(:oauth_provider){ OauthProvider.create! name: 'twitter', key: 'dummy_key', secret: 'dummy_secret' }
    let(:oauth_provider_fb){ OauthProvider.create! name: 'facebook', key: 'dummy_key', secret: 'dummy_secret' }
    before{ oauth_provider }
    before{ oauth_provider_fb }
    subject{ created_user }
    its(:email){ should == auth['info']['email'] }
    its(:name){ should == auth['info']['name'] }
    its(:nickname){ should == auth['info']['nickname'] }
    its(:bio){ should == auth['info']['description'][0..139] }

    describe "when user is merging facebook account" do
      let(:user) { create(:user, name: 'Test', email: 'test@test.com') }
      let(:created_user){ User.create_with_omniauth(auth, user) }

      subject { created_user }

      its(:email) { should == 'test@test.com' }
      it { subject.authorizations.first.uid.should == auth['uid'] }
    end

    describe "when user is not logged in and logs in with a facebook account with the same email" do
      let(:user) { create(:user, name: 'Test', email: 'another_email@anotherdomain.com') }
      let(:created_user){ user; User.create_with_omniauth(auth) }

      subject { created_user }

      its(:id) { should == user.id }
      its(:email) { should == 'another_email@anotherdomain.com' }
      it { subject.authorizations.first.uid.should == auth['uid'] }
    end

    describe "created user's authorizations" do
      subject{ created_user.authorizations.first }
      its(:uid){ should == auth['uid'] }
      its(:oauth_provider_id){ should == oauth_provider.id }
    end

    context "when user is from facebook" do
      let(:auth)  do {
        'provider' => "facebook",
        'uid' => "foobar",
        'info' => {
          'name' => "Foo bar",
          'email' => 'another_email@anotherdomain.com',
          'nickname' => "foobar",
          'description' => "Foo bar's bio".ljust(200),
          'image' => "image.png"
        }
      }
      end
      its(:image_url){ should == "https://graph.facebook.com/#{auth['uid']}/picture?type=large" }
    end
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

  describe "#total_backed_projects" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    subject { user.total_backed_projects }

    before do
      create(:backer, state: 'confirmed', user: user, project: project)
      create(:backer, state: 'confirmed', user: user, project: project)
      create(:backer, state: 'confirmed', user: user, project: project)
      create(:backer, state: 'confirmed', user: user)
    end

    it { should == 2}
  end

  describe "#credits" do
    before do
      @u = create(:user)
      create(:backer, state: 'confirmed', credits: false, value: 100, user_id: @u.id, project: successful_project)
      create(:backer, state: 'confirmed', credits: false, value: 100, user_id: @u.id, project: unfinished_project)
      create(:backer, state: 'confirmed', credits: false, value: 200, user_id: @u.id, project: failed_project)
      create(:backer, state: 'confirmed', credits: true, value: 100, user_id: @u.id, project: successful_project)
      create(:backer, state: 'confirmed', credits: true, value: 50, user_id: @u.id, project: unfinished_project)
      create(:backer, state: 'confirmed', credits: true, value: 100, user_id: @u.id, project: failed_project)
      create(:backer, state: 'requested_refund', credits: false, value: 200, user_id: @u.id, project: failed_project)
      create(:backer, state: 'refunded', credits: false, value: 200, user_id: @u.id, project: failed_project)
      failed_project.update_attributes state: 'failed'
      successful_project.update_attributes state: 'successful'
    end

    subject{ @u.credits }

    it{ should == 50.0 }
  end

  describe "#update_attributes" do
    context "when I try to update moip_login" do
      before do
        user.update_attributes moip_login: 'test'
      end
      it("should perform the update"){ user.moip_login.should == 'test' }
    end
  end

  describe "#recommended_project" do
    subject{ user.recommended_projects }
    before do
      other_backer = create(:backer, state: 'confirmed')
      create(:backer, state: 'confirmed', user: other_backer.user, project: unfinished_project)
      create(:backer, state: 'confirmed', user: user, project: other_backer.project)
    end
    it{ should == [unfinished_project]}
  end

  describe "#updates_subscription" do
    subject{user.updates_subscription}
    context "when user is subscribed to all projects" do
      before{ notification_type }
      it{ should be_new_record }
    end
    context "when user is unsubscribed from all projects" do
      before { @u = create(:unsubscribe, project_id: nil, notification_type_id: notification_type.id, user_id: user.id )}
      it{ should == @u}
    end
  end

  describe "#project_unsubscribes" do
    subject{user.project_unsubscribes}
    before do
      @p1 = create(:project)
      create(:backer, user: user, project: @p1)
      @u1 = create(:unsubscribe, project_id: @p1.id, notification_type_id: notification_type.id, user_id: user.id )
    end
    it{ should == [@u1]}
  end

  describe "#backed_projects" do
    subject{user.backed_projects}
    before do
      @p1 = create(:project)
      create(:backer, user: user, project: @p1)
      create(:backer, user: user, project: @p1)
    end
    it{should == [@p1]}
  end

  describe "#facebook_id" do
    subject{ user.facebook_id }
    context "when user have a FB authorization" do
      let(:user){ create(:user, authorizations: [ create(:authorization, uid: 'bar', oauth_provider: facebook_provider)]) }
      it{ should == 'bar' }
    end
    context "when user do not have a FB authorization" do
      let(:user){ create(:user) }
      it{ should == nil }
    end
  end

  describe "#fix_facebook_link" do
    subject{ user.facebook_link }
    context "when user provides invalid url" do
      let(:user){ create(:user, facebook_link: 'facebook.com/foo') }
      it{ should == 'http://facebook.com/foo' }
    end
    context "when user provides valid url" do
      let(:user){ create(:user, facebook_link: 'http://facebook.com/foo') }
      it{ should == 'http://facebook.com/foo' }
    end
  end

  describe "#trustee?" do
    let(:user) { create(:user) }

    context "when user is a moderator of one or more channels" do
      it "should return true" do
        user.channels << create(:channel)
        expect(user.trustee?).to eq(true)
      end
    end

    context "when user is not a moderator of any channels" do
      it "should return false" do
        expect(user.trustee?).to eq(false)
      end
    end

  end

end
