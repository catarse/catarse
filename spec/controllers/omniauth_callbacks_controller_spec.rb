require 'spec_helper'

describe OmniauthCallbacksController do
  before do
    facebook_provider
    OmniauthCallbacksController.add_providers
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:return_to){ nil }
  let(:user){ FactoryGirl.create(:user, authorizations: [ FactoryGirl.create(:authorization, uid: oauth_data[:uid], oauth_provider: facebook_provider ) ]) }
  let(:facebook_provider){ FactoryGirl.create :oauth_provider, name: 'facebook' }
  let(:oauth_data){
    Hashie::Mash.new({
      credentials: {
        expires: true,
        expires_at: 1366644101,
        token: "AAAHuZCwF61OkBAOmLTwrhv52pZCriPnTGIasdasdasdascNhZCZApsZCSg6POZCQqolxYjnqLSVH67TaRDONx72fXXXB7N7ZBByLZCV7ldvagm"
      },
      extra: {
        raw_info: {
          bio: "I, simply am not there",
          email: "diogob@gmail.com",
          first_name: "Diogo",
          gender: "male",
          id: "547955110",
          last_name: "Biazus",
          link: "http://www.facebook.com/diogo.biazus",
          locale: "pt_BR",
          name: "Diogo, Biazus",
          timezone: -3,
          updated_time: "2012-08-01T18:22:50+0000",
          username: "diogo.biazus",
          verified: true
        },
      },
      info: {
        description: "I, simply am not there",
        email: "diogob@gmail.com",
        first_name: "Diogo",
        image: "http://graph.facebook.com/547955110/picture?type:, square",
        last_name: "Biazus",
        name: "Diogo, Biazus",
        nickname: "diogo.biazus",
        urls: {
          Facebook: "http://www.facebook.com/diogo.biazus"
        },
        verified: true
      },
      provider: "facebook",
      uid: "547955110"
    })
  }

  subject{ response }

  describe ".add_providers" do
    subject{ controller }
    it{ should respond_to(:facebook) }
  end

  describe "GET facebook" do

    describe "when user already loged in" do
      let(:user) { FactoryGirl.create(:user, name: 'Foo') }

      before do
        controller.stub(:current_user).and_return(user)
        session[:return_to] = return_to
        request.env['omniauth.auth'] = oauth_data
        get :facebook
      end

      describe "assigned user" do
        subject{ assigns(:user) }
        its(:name){ should == "Foo" }
        it { subject.authorizations.should have(1).item }
      end

      it{ should redirect_to root_path }
    end

    describe 'when user not loged in' do
      before do
        user
        session[:return_to] = return_to
        request.env['omniauth.auth'] = oauth_data
        get :facebook
      end

      context "when there is no such user but we retrieve the email from omniauth" do
        let(:user){ nil }
        describe "assigned user" do
          subject{ assigns(:user) }
          its(:email){ should == "diogob@gmail.com" }
          its(:name){ should == "Diogo, Biazus" }
        end
        it{ should redirect_to root_path }
      end

      context "when there is a valid user with this provider and uid and session return_to is /foo" do
        let(:return_to){ '/foo' }
        it{ assigns(:user).should == user }
        it{ should redirect_to '/foo' }
      end

      context "when there is a valid user with this provider and uid and session return_to is nil" do
        it{ assigns(:user).should == user }
        it{ should redirect_to root_path }
      end
    end
  end
end
