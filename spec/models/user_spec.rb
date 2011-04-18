require 'spec_helper'

describe User do
  it "should be valid from factory" do
    u = Factory(:user)
    u.should be_valid
  end
  it "User.primary should return all primary users" do
    u = Factory(:user)
    secondary = Factory(:user, :email => u.email)
    User.primary.all.should == [u]
  end
  it "primary should return the primary user for this instance" do
    u = Factory(:user)
    secondary = Factory(:user, :email => u.email)
    secondary.primary.should == u
  end
  it "secondary_users should return the secondary users for this instance" do
    u = Factory(:user)
    secondary = Factory(:user, :email => u.email)
    another_user = Factory(:user, :email => u.email)
    Set.new(u.secondary_users).should == Set.new([secondary, another_user])
  end
  it "if we already have a user with the same email it should be associated with the first user" do
    u = Factory(:user)
    secondary = Factory(:user, :email => u.email)
    secondary.primary_user_id.should == u.id
    another_user = Factory(:user, :email => u.email)
    another_user.primary_user_id.should == u.id
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
  it "should create and not associate user passed as parameter if email association suvcceeds" do
    primary = Factory(:user)
    another_user = Factory(:user)
    auth = {
      'provider' => "twitter",
      'uid' => "foobar",
      'user_info' => {
        'name' => "Foo bar",
        'email' => primary.email,
        'nickname' => "foobar",
        'description' => "Foo bar's bio".ljust(200),
        'image' => "user.png"
      }
    }
    u = User.create_with_omniauth(Factory(:site), auth, another_user.id)
    u.should == primary
    User.count.should == 3
  end
  it "should create and associate user passed as parameter if email association fails" do
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

  it "should create a new user receiving a omniauth hash and always return the primary user" do
    primary = Factory(:user)
    auth = {
      'provider' => "twitter",
      'uid' => "foobar",
      'user_info' => {
        'name' => "Foo bar",
        'email' => primary.email,
        'nickname' => "foobar",
        'description' => "Foo bar's bio".ljust(200),
        'image' => "user.png"
      }
    }
    u = User.create_with_omniauth(Factory(:site), auth)
    u.should == primary
    User.count.should == 2
  end
  it "should have a find_with_omniauth who finds always the primary" do
    primary = Factory(:user)
    secondary = Factory(:user, :email => primary.email)
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
    u.display_name.should == "Sem nome"
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
end

