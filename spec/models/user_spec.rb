require 'spec_helper'

describe User do
  let(:user){ Factory(:user, :provider => "foo", :uid => "bar") }

  describe "associations" do
    it{ should have_many :backs }
    it{ should have_many :projects }
    it{ should have_many :notifications }
    it{ should have_many :secondary_users }
    it{ should have_many :updates }
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

  describe ".primary" do
    subject{ Factory(:user, :primary_user_id => user.id).primary }
    it{ should == user }
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
end
