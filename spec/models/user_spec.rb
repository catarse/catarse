require 'spec_helper'

describe User do
  context "#display_nickname" do
    it "when user don't have the nickname" do
      user = create(:user,:name=>'Lorem Ipsum',:nickname=>'profile.php?id=1234')
      user.display_nickname.should == 'Lorem Ipsum'
    end

    it 'user with nickname' do
      user = create(:user,:name=>'Lorem Ipsum',:nickname=>'lorem.ipsum')
      user.display_nickname.should == 'lorem.ipsum'
    end
  end

  it "should be valid from factory" do
    u = Factory(:user)
    u.should be_valid
  end
  it "User.primary should return all primary users" do
    u = Factory(:user)
    secondary = Factory(:user, :primary_user_id => u.id)
    User.primary.all.should == [u]
  end
  it "primary should return the primary user for this instance" do
    u = Factory(:user)
    secondary = Factory(:user, :primary_user_id => u.id)
    secondary.primary.should == u
  end
  it "secondary_users should return the secondary users for this instance" do
    u = Factory(:user)
    secondary = Factory(:user, :primary_user_id => u.id)
    another_user = Factory(:user, :primary_user_id => u.id)
    Set.new(u.secondary_users).should == Set.new([secondary, another_user])
  end
  it "even if we already have a user with the same email it should not be automatically associated with the first user" do
    u = Factory(:user)
    secondary = Factory(:user, :email => u.email)
    secondary.primary_user_id.should == nil
    another_user = Factory(:user, :email => u.email)
    another_user.primary_user_id.should == nil
  end
  it "should have a provider" do
    u = Factory.build(:user, :provider => nil)
    u.should_not be_valid
  end
  it "should have an uid" do
    u = Factory.build(:user, :uid => nil)
    u.should_not be_valid
  end
  it "should not have duplicate provider and uid" do
    u = Factory.build(:user, :provider => "twitter", :uid => "123456")
    u.should be_valid
    u.save
    u = Factory.build(:user, :provider => "twitter", :uid => "123456")
    u.should_not be_valid
  end
  it "should allow empty email" do
    u = Factory.build(:user)
    u.email = ""
    u.should be_valid
    u.email = nil
    u.should be_valid
  end
  it "should check email format" do
    u = Factory.build(:user)
    u.email = "foo"
    u.should_not be_valid
    u.email = "foo@bar"
    u.should_not be_valid
    u.email = "foo@bar.com"
    u.should be_valid
  end
  it "should not be valid with a bio longer than 140 characters" do
    u = Factory.build(:user)
    u.bio = "a".center(139)
    u.should be_valid
    u.bio = "a".center(140)
    u.should be_valid
    u.bio = "a".center(141)
    u.should_not be_valid
  end
  it "should create and associate user passed as parameter if passed" do
    primary = Factory(:user)
    auth = {
      'provider' => "twitter",
      'uid' => "foobar",
      'user_info' => {
        'name' => "Foo bar",
        'email' => 'another_email@catarse.me',
        'nickname' => "foobar",
        'description' => "Foo bar's bio".ljust(200),
        'image' => "user.png"
      }
    }
    u = User.create_with_omniauth(Factory(:site), auth, primary.id)
    u.should == primary
    User.count.should == 2
  end
  it "should have a find_with_omniauth who finds always the primary" do
    primary = Factory(:user)
    secondary = Factory(:user, :primary_user_id => primary.id)
    User.find_with_omni_auth(primary.provider, primary.uid).should == primary
    User.find_with_omni_auth(secondary.provider, secondary.uid).should == primary
    # If user does not exist just returns nil
    User.find_with_omni_auth(secondary.provider, 'user that does not exist').should == nil
  end
  it "should create a new user receiving a omniauth hash" do
    auth = {
      'provider' => "twitter",
      'uid' => "foobar",
      'user_info' => {
        'name' => "Foo bar",
        'nickname' => "foobar",
        'description' => "Foo bar's bio".ljust(200),
        'image' => "user.png"
      }
    }
    u = User.create_with_omniauth(Factory(:site), auth)
    u.should be_valid
    u.provider.should == auth['provider']
    u.uid.should == auth['uid']
    u.name.should == auth['user_info']['name']
    u.nickname.should == auth['user_info']['nickname']
    u.bio.should == auth['user_info']['description'][0..139]
    u.image_url.should == auth['user_info']['image']
  end
  it "should have a display_name that shows the name, nickname or 'Sem nome'" do
    u = Factory(:user, :name => "Name")
    u.display_name.should == "Name"
    u = Factory(:user, :name => nil, :nickname => "Nickname")
    u.display_name.should == "Nickname"
    u = Factory(:user, :name => nil, :nickname => nil)
    u.display_name.should == I18n.t('user.no_name')
  end
  it "should have a display_image that shows the user's image or user.png when email is null" do
    u = Factory(:user, :image_url => "image.png", :email => nil)
    u.display_image.should == "image.png"
    u = Factory(:user, :image_url => nil, :email => nil)
    u.display_image.should == "/images/user.png"
  end
  it "should insert a gravatar in user's image if there is one available" do
    u = Factory(:user, :image_url => nil, :email => 'diogob@gmail.com')
    u.display_image.should == "http://gravatar.com/avatar/5e2a237dafbc45f79428fdda9c5024b1.jpg?default=http://catarse.me/images/user.png"
  end
  it "should have a remember_me_hash with the MD5 of the provider + ## + uid" do
    u = Factory(:user, :provider => "foo", :uid => "bar")
    u.remember_me_hash.should == "27fc6690fafccbb0fc0b8f84c6749644"
  end
  it "should merge into another account, taking the credits, backs, projects, comments and notifications with it" do
    old_user = Factory(:user, :credits => 50)
    new_user = Factory(:user, :credits => 20)
    backed_project = Factory(:project)
    old_user_back = backed_project.backers.create!(:site => backed_project.site, :user => old_user, :value => 10)
    new_user_back = backed_project.backers.create!(:site => backed_project.site, :user => new_user, :value => 10)
    old_user_project = Factory(:project, :user => old_user)
    new_user_project = Factory(:project, :user => new_user)
    old_user_comment = backed_project.comments.create!(:user => old_user, :comment => "Foo bar")
    new_user_comment = backed_project.comments.create!(:user => new_user, :comment => "Foo bar")
    old_user_notification = old_user.notifications.create!(:site => backed_project.site, :text => "Foo bar")
    new_user_notification = new_user.notifications.create!(:site => backed_project.site, :text => "Foo bar")

    old_user.credits.should == 50
    new_user.credits.should == 20
    old_user.backs.should == [old_user_back]
    new_user.backs.should == [new_user_back]
    old_user.projects.should == [old_user_project]
    new_user.projects.should == [new_user_project]
    old_user.comments.should == [old_user_comment]
    new_user.comments.should == [new_user_comment]
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
    old_user.comments.should == []
    new_user.comments.order(:created_at).should == [old_user_comment, new_user_comment]
    old_user.notifications.should == []
    new_user.notifications.order(:created_at).should == [old_user_notification, new_user_notification]
  end
end


# == Schema Information
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  primary_user_id       :integer
#  provider              :text            not null
#  uid                   :text            not null
#  email                 :text
#  name                  :text
#  nickname              :text
#  bio                   :text
#  image_url             :text
#  newsletter            :boolean         default(FALSE)
#  project_updates       :boolean         default(FALSE)
#  created_at            :datetime
#  updated_at            :datetime
#  admin                 :boolean         default(FALSE)
#  full_name             :text
#  address_street        :text
#  address_number        :text
#  address_complement    :text
#  address_neighbourhood :text
#  address_city          :text
#  address_state         :text
#  address_zip_code      :text
#  phone_number          :text
#  credits               :decimal(, )     default(0.0)
#  site_id               :integer         default(1), not null
#  session_id            :text
#  locale                :text            default("pt"), not null
#

