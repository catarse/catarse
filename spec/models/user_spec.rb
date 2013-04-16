require 'spec_helper'

describe User do
  let(:user){ FactoryGirl.create(:user, :provider => "foo", :uid => "bar") }
  let(:unfinished_project){ FactoryGirl.create(:project, state: 'online') }
  let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed') }
  let(:notification_type){ FactoryGirl.create(:notification_type, name: 'updates') }
  let(:facebook_provider){ FactoryGirl.create :oauth_provider, name: 'facebook' }

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
    it{ should allow_value('').for(:email) }
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
        b = FactoryGirl.create(:backer, :value => 100, :project => failed_project)
        @u = b.user
        b = FactoryGirl.create(:backer, :value => 100, :project => successful_project)
      end
      it{ should == [@u] }
    end
  end

  describe ".by_payer_email" do
    before do
      p = FactoryGirl.create(:payment_notification)
      backer = p.backer
      @u = backer.user
      p.extra_data = {'payer_email' => 'foo@bar.com'}
      p.save!
      p = FactoryGirl.create(:payment_notification, :backer => backer)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
      p = FactoryGirl.create(:payment_notification)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
    end
    subject{ User.by_payer_email 'foo@bar.com' }
    it{ should == [@u] }
  end

  describe ".by_key" do
    before do
      b = FactoryGirl.create(:backer)
      @u = b.user
      b.key = 'abc'
      b.save!
      b = FactoryGirl.create(:backer, :user => @u)
      b.key = 'abcde'
      b.save!
      b = FactoryGirl.create(:backer)
      b.key = 'def'
      b.save!
    end
    subject{ User.by_key 'abc' }
    it{ should == [@u] }
  end

  describe ".by_id" do
    before do
      @u = FactoryGirl.create(:user)
      FactoryGirl.create(:user)
    end
    subject{ User.by_id @u.id }
    it{ should == [@u] }
  end

  describe ".by_name" do
    before do
      @u = FactoryGirl.create(:user, :name => 'Foo Bar')
      FactoryGirl.create(:user, :name => 'Baz Qux')
    end
    subject{ User.by_name 'Bar' }
    it{ should == [@u] }
  end

  describe ".by_email" do
    before do
      @u = FactoryGirl.create(:user, :email => 'foo@bar.com')
      FactoryGirl.create(:user, :email => 'another_email@bar.com')
    end
    subject{ User.by_email 'foo@bar' }
    it{ should == [@u] }
  end
  


  describe ".who_backed_project" do
    subject{ User.who_backed_project(successful_project.id) }
    before do
      @backer = FactoryGirl.create(:backer, :confirmed => true, :project => successful_project)
      FactoryGirl.create(:backer, :confirmed => true, :project => successful_project, :user => @backer.user)
      FactoryGirl.create(:backer, :confirmed => false, :project => successful_project)
    end
    it{ should == [@backer.user] }
  end

  describe ".backer_totals" do
    before do
      FactoryGirl.create(:backer, :value => 100, :credits => false, :project => successful_project)
      FactoryGirl.create(:backer, :value => 50, :credits => false, :project => successful_project)
      user = FactoryGirl.create(:backer, :value => 25, :project => failed_project).user
      user.save!
      @u = FactoryGirl.create(:user)
    end

    context "when we call upon user without backs" do
      subject{ User.where(:id => @u.id).backer_totals }
      it{ should == {:users => 0.0, :backers => 0.0, :backed => 0.0, :credits => 0.0} }
    end

    context "when we call without scopes" do
      subject{ User.backer_totals }
      it{ should == {:users => 3.0, :backers => 3.0, :backed => 175.0, :credits => 25.0} }
    end

    context "when we call with scopes" do
      subject{ User.has_credits.backer_totals }
      it{ should == {:users => 1.0, :backers => 1.0, :backed => 25.0, :credits => 25.0} }
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
    before{ oauth_provider }
    subject{ created_user }
    # Provider and uid should be nil because we have transfered them to authorization model
    its(:provider){ should be_nil }
    its(:uid){ should be_nil }
    its(:email){ should == auth['info']['email'] }
    its(:name){ should == auth['info']['name'] }
    its(:nickname){ should == auth['info']['nickname'] }
    its(:bio){ should == auth['info']['description'][0..139] }
    
    describe "when user is merging your facebook account" do
      let(:user) { FactoryGirl.create(:user, provider: nil, name: 'Test', email: 'test@test.com') }
      let(:created_user){ User.create_with_omniauth(auth, user) }

      subject { created_user }
      
      its(:email) { should == 'test@test.com' }
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
        u.provider = 'twitter'
        u.uid = '123'
        u.twitter = '@dbiazus'
      end
    end
    its(:twitter){ should == 'dbiazus' }
  end

  describe "#credits" do
    before do
      @u = FactoryGirl.create(:user)
      FactoryGirl.create(:backer, :credits => false, :value => 100, :user_id => @u.id, :project => successful_project)
      FactoryGirl.create(:backer, :credits => false, :value => 100, :user_id => @u.id, :project => unfinished_project)
      FactoryGirl.create(:backer, :credits => false, :value => 200, :user_id => @u.id, :project => failed_project)
      FactoryGirl.create(:backer, :credits => true, :value => 100, :user_id => @u.id, :project => successful_project)
      FactoryGirl.create(:backer, :credits => true, :value => 50, :user_id => @u.id, :project => unfinished_project)
      FactoryGirl.create(:backer, :credits => true, :value => 100, :user_id => @u.id, :project => failed_project)
      FactoryGirl.create(:backer, :credits => false, :requested_refund => true, :value => 200, :user_id => @u.id, :project => failed_project)
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
    subject{user.recommended_project}
    before do
      user2, p1, @p2, @p3 = FactoryGirl.create(:user),FactoryGirl.create(:project), FactoryGirl.create(:project, state: :online), FactoryGirl.create(:project, state: :draft)
      FactoryGirl.create(:backer, :user => user2, :project => p1)
      FactoryGirl.create(:backer, :user => user2, :project => @p2)
      FactoryGirl.create(:backer, :user => user2, :project => @p3)
      FactoryGirl.create(:backer, :user => user, :project => p1)
    end
    it{ should == @p2}
  end

  describe "#updates_subscription" do
    subject{user.updates_subscription}
    context "when user is subscribed to all projects" do
      before{ notification_type }
      it{ should be_new_record }
    end
    context "when user is unsubscribed from all projects" do
      before { @u = FactoryGirl.create(:unsubscribe, project_id: nil, notification_type_id: notification_type.id, user_id: user.id )}
      it{ should == @u}
    end
  end

  describe "#project_unsubscribes" do
    subject{user.project_unsubscribes}
    before do
      @p1 = FactoryGirl.create(:project)
      FactoryGirl.create(:backer, user: user, project: @p1)
      @u1 = FactoryGirl.create(:unsubscribe, project_id: @p1.id, notification_type_id: notification_type.id, user_id: user.id )
    end
    it{ should == [@u1]}
  end

  describe "#backed_projects" do
    subject{user.backed_projects}
    before do
      @p1 = FactoryGirl.create(:project)
      FactoryGirl.create(:backer, user: user, project: @p1)
      FactoryGirl.create(:backer, user: user, project: @p1)
    end
    it{should == [@p1]}
  end

  describe "#remember_me_hash" do
    subject{ FactoryGirl.create(:user, :provider => "foo", :uid => "bar").remember_me_hash }
    it{ should == "27fc6690fafccbb0fc0b8f84c6749644" }
  end

  describe "#facebook_id" do
    subject{ user.facebook_id }
    context "when user have a FB authorization" do
      let(:user){ FactoryGirl.create(:user, authorizations: [ FactoryGirl.create(:authorization, uid: 'bar', oauth_provider: facebook_provider)]) }
      it{ should == 'bar' }
    end
    context "when user do not have a FB authorization" do
      let(:user){ FactoryGirl.create(:user) }
      it{ should == nil }
    end
  end
  
  describe "#trustee?" do
    let(:user) { FactoryGirl.create(:user) }

    context "when user is a moderator of one or more channels" do
      it "should return true" do
        user.channels << FactoryGirl.create(:channel)
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
