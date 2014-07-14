require 'spec_helper'

describe User::OmniauthHandler do
  let(:user){ create(:user) }
  let(:facebook_provider){ create :oauth_provider, name: 'facebook' }

  subject { user }

  describe "Associations" do
    it{ should have_many(:oauth_providers).through(:authorizations) }
  end

  describe ".create_from_hash" do
    let(:auth)  do {
      'provider' => "facebook",
      'uid' => "foobar",
      'info' => {
        'name' => "Foo bar",
        'email' => 'another_email@anotherdomain.com',
        'description' => "Foo bar's bio".ljust(200),
        'image' => "image.png"
      }
    }
    end
    subject{ User.create_from_hash(auth) }
    it{ should be_persisted }
    its(:email){ should == auth['info']['email'] }
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

  describe "#has_facebook_authentication?" do
    subject { user.has_facebook_authentication? }
    context "when user has a facebook account linked" do
      before do
        create(:authorization, user: user, oauth_provider: facebook_provider)
      end

      it { should be_true }
    end

    context "when user don't has a facebook account linked" do
      it { should be_false }
    end
  end
end
