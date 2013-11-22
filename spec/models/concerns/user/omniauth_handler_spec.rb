require 'spec_helper'

describe User::OmniauthHandler do

  describe ".find_via_omniauth" do
    let(:oauth_provider){ create(:oauth_provider, name: 'facebook', key: 'dummy_key', secret: 'dummy_secret') }
    let(:auth) do
      { uid: '1234', provider: 'facebook' }
    end

    context "when have user with authorization" do
      let(:authorization) { create(:authorization, oauth_provider: oauth_provider, uid: '1234') }

      before do
        authorization
      end

      subject { User.find_via_omniauth(auth, oauth_provider.name) }

      it { should == authorization.user }
    end

    context "when not have user with authorization" do
      subject { User.find_via_omniauth(auth, oauth_provider.name) }

      it { should be_nil }
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


end
