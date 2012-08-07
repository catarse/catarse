require 'spec_helper'

describe User do
  let(:user){ Factory(:user, :provider => "foo", :uid => "bar") }
  let(:unfinished_project){ Factory(:project, :finished => false, :successful => true) }
  let(:successful_project){ Factory(:project, :finished => true, :successful => true) }
  let(:failed_project){ Factory(:project, :finished => true, :successful => false) }

  describe "associations" do
    it{ should have_many :backs }
    it{ should have_many :projects }
    it{ should have_many :notifications }
    it{ should have_many :secondary_users }
    it{ should have_many :updates }
    it{ should have_one :backer_total }
  end

  describe "validations" do 
    before{ user }
    it{ should validate_presence_of :provider }
    it{ should validate_presence_of :uid }
    it{ should allow_value('').for(:email) }
    it{ should allow_value('foo@bar.com').for(:email) }
    it{ should_not allow_value('foo').for(:email) }
    it{ should_not allow_value('foo@bar').for(:email) }
    it{ should allow_value('a'.center(139)).for(:bio) }
    it{ should allow_value('a'.center(140)).for(:bio) }
    it{ should_not allow_value('a'.center(141)).for(:bio) }
    it{ should validate_uniqueness_of(:uid).scoped_to(:provider) }
  end

  describe ".has_credits" do
    subject{ User.has_credits }

    context "when he has credits in the user table" do
      before do
        @u = Factory(:user, :credits => 100)
        Factory(:backer, :project => successful_project, :user => @u)
        Factory(:user, :credits => 0)
        Factory(:backer, :project => successful_project)
      end
      it{ should == [@u] }
    end

    context "when he has credits in the backer_total" do
      before do
        b = Factory(:backer, :value => 100, :project => failed_project)
        @u = b.user
        b = Factory(:backer, :value => 100, :project => successful_project)
      end
      it{ should == [@u] }
    end
  end

  describe ".by_key" do
    before do
      b = Factory(:backer)
      @u = b.user
      b.key = 'abc'
      b.save!
      b = Factory(:backer, :user => @u)
      b.key = 'abcde'
      b.save!
      b = Factory(:backer)
      b.key = 'def'
      b.save!
    end
    subject{ User.by_key 'abc' }
    it{ should == [@u] }
  end

  describe ".by_id" do
    before do
      @u = Factory(:user)
      Factory(:user)
    end
    subject{ User.by_id @u.id }
    it{ should == [@u] }
  end

  describe ".by_name" do
    before do
      @u = Factory(:user, :name => 'Foo Bar')
      Factory(:user, :name => 'Baz Qux')
    end
    subject{ User.by_name 'Bar' }
    it{ should == [@u] }
  end

  describe ".by_email" do
    before do
      @u = Factory(:user, :email => 'foo@bar.com')
      Factory(:user, :email => 'another_email@bar.com')
    end
    subject{ User.by_email 'foo@bar' }
    it{ should == [@u] }
  end

  describe ".primary" do
    subject{ Factory(:user, :primary_user_id => user.id).primary }
    it{ should == user }
  end

  describe ".backer_totals" do
    before do
      Factory(:backer, :value => 100)
      Factory(:backer, :value => 50)
      user = Factory(:backer, :value => 25, :project => failed_project).user
      user.credits = 10.0
      user.save!
      @u = Factory(:user)
    end

    context "when we call upon user without backs" do
      subject{ User.where(:id => @u.id).backer_totals }
      it{ should == {:backers => 0.0, :backed => 0.0, :credits => 0.0, :credits_table => 0.0} }
    end

    context "when we call without scopes" do
      subject{ User.backer_totals }
      it{ should == {:backers => 3.0, :backed => 175.0, :credits => 25.0, :credits_table => 10.0} }
    end

    context "when we call with scopes" do
      subject{ User.has_credits.backer_totals }
      it{ should == {:backers => 1.0, :backed => 25.0, :credits => 25.0, :credits_table => 10.0} }
    end
  end

  describe ".create_with_omniauth" do
    let(:auth) do {
        'provider' => "twitter",
        'uid' => "foobar",
        'info' => {
          'name' => "Foo bar",
          'email' => 'another_email@anotherdomain.com',
          'nickname' => "foobar",
          'description' => "Foo bar's bio".ljust(200),
          'image' => "user.png"
        }
      }
    end
    subject{ User.create_with_omniauth(auth) }
    its(:provider){ should == auth['provider'] }
    its(:uid){ should == auth['uid'] }
    its(:name){ should == auth['info']['name'] }
    its(:nickname){ should == auth['info']['nickname'] }
    its(:bio){ should == auth['info']['description'][0..139] }
    its(:image_url){ should == auth['info']['image'] }
  end

  describe ".find_with_omniauth" do
    let(:primary){ Factory(:user) }
    let(:secondary){ Factory(:user, :primary_user_id => primary.id) }
    it{ User.find_with_omni_auth(primary.provider, primary.uid).should == primary }
    it{ User.find_with_omni_auth(secondary.provider, secondary.uid).should == primary }
    it{ User.find_with_omni_auth(secondary.provider, 'user that does not exist').should == nil }
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

  describe "#calculate_credits" do
    before do
      @u = Factory(:user)
      Factory(:backer, :credits => false, :value => 100, :user_id => @u.id, :project => successful_project)
      Factory(:backer, :credits => false, :value => 100, :user_id => @u.id, :project => unfinished_project)
      Factory(:backer, :credits => false, :value => 200, :user_id => @u.id, :project => failed_project)
      Factory(:backer, :credits => true, :value => 100, :user_id => @u.id, :project => successful_project)
      Factory(:backer, :credits => true, :value => 50, :user_id => @u.id, :project => unfinished_project)
      Factory(:backer, :credits => true, :value => 100, :user_id => @u.id, :project => failed_project)
      Factory(:backer, :credits => false, :requested_refund => true, :value => 200, :user_id => @u.id, :project => failed_project)
    end
    subject{ @u.calculate_credits }
    it{ should == 50.0 }
  end

  describe "#primary" do
    subject{ Factory(:user, :primary_user_id => user.id).primary }
    it{ should == user }
  end

  describe "#secondary_users" do
    before do
      @secondary = Factory(:user, :primary_user_id => user.id)
      Factory(:user)
    end
    subject{ user.secondary_users }
    it{ should == [@secondary] }
  end

  describe "#recommended_project" do
    subject{user.recommended_project}
    before do
      user2, p1, @p2 = Factory(:user),Factory(:project), Factory(:project)
      Factory(:backer, :user => user2, :project => p1)
      Factory(:backer, :user => user2, :project => @p2)
      Factory(:backer, :user => user, :project => p1)
    end
    it{ should == @p2}
  end

  describe "#display_name" do
    subject{ user.display_name }
    context "when we have a name" do
      let(:user){ Factory(:user, :name => "Name") }
      it{ should == 'Name' }
    end
    context "when we have only a nickname" do
      let(:user){ Factory(:user, :name => nil, :nickname => 'nick') }
      it{ should == 'nick' }
    end
    context "when we have no name" do
      let(:user){ Factory(:user, :name => nil, :nickname => nil) }
      it{ should == I18n.t('user.no_name') }
    end
  end

  describe "#display_image" do
    subject{ user.display_image }
    context "when we have an image" do
      let(:user){ Factory(:user, :image_url => "image.png", :email => nil) }
      it{ should == 'image.png' }
    end
    context "when we have an email" do
      let(:user){ Factory(:user, :image_url => nil, :email => 'diogob@gmail.com') }
      it{ should == "http://gravatar.com/avatar/5e2a237dafbc45f79428fdda9c5024b1.jpg?default=#{I18n.t('site.base_url')}/assets/user.png" }
    end
    context "when we do not have an image nor an email" do
      let(:user){ Factory(:user, :image_url => nil, :email => nil) }
      it{ should == '/assets/user.png' }
    end
  end

  describe "#remember_me_hash" do
    subject{ Factory(:user, :provider => "foo", :uid => "bar").remember_me_hash }
    it{ should == "27fc6690fafccbb0fc0b8f84c6749644" }
  end

  describe "#facebook_id" do
    subject{ user.facebook_id }
    context "when primary is a FB user" do
      let(:user){ Factory(:user, :provider => "facebook", :uid => "bar") }
      it{ should == 'bar' }
    end
    context "when primary is another provider's user and there is no secondary" do
      let(:user){ Factory(:user, :provider => "foo", :uid => "bar") }
      it{ should be_nil }
    end
    context "when primary is another provider's user but there is a secondary FB user" do
      let(:user){ Factory(:user, :provider => "foo", :uid => "bar", :secondary_users => [Factory(:user, :provider => "facebook", :uid => "bar")]) }
      it{ should == 'bar' }
    end
  end

  describe "#merge_into!" do
    it "should merge into another account, taking the credits, backs, projects and notifications with it" do
      old_user = Factory(:user, :credits => 50)
      new_user = Factory(:user, :credits => 20)
      backed_project = Factory(:project)
      old_user_back = backed_project.backers.create!(:user => old_user, :value => 10)
      new_user_back = backed_project.backers.create!(:user => new_user, :value => 10)
      old_user_project = Factory(:project, :user => old_user)
      new_user_project = Factory(:project, :user => new_user)
      old_user_notification = old_user.notifications.create!(:text => "Foo bar")
      new_user_notification = new_user.notifications.create!(:text => "Foo bar")

      old_user.credits.should == 50
      new_user.credits.should == 20
      old_user.backs.should == [old_user_back]
      new_user.backs.should == [new_user_back]
      old_user.projects.should == [old_user_project]
      new_user.projects.should == [new_user_project]
      old_user.notifications.should == [old_user_notification]
      new_user.notifications.should == [new_user_notification]

      old_user.merge_into!(new_user)
      old_user.reload
      new_user.reload

      old_user.primary.should == new_user
      old_user.credits.should == 0
      new_user.credits.should == 70
      old_user.backs.should == []
      new_user.backs.order(:created_at).should == [old_user_back, new_user_back]
      old_user.projects.should == []
      new_user.projects.order(:created_at).should == [old_user_project, new_user_project]
      old_user.notifications.should == []
      new_user.notifications.order(:created_at).should == [old_user_notification, new_user_notification]
    end
  end
end
