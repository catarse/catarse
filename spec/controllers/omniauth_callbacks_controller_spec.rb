require 'spec_helper'

describe OmniauthCallbacksController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:return_to){ nil }
  let(:user){ FactoryGirl.create(:user, authorizations: [ FactoryGirl.create(:authorization, uid: oauth_data[:uid], oauth_provider: facebook_provider ) ]) }
  let(:facebook_provider){ FactoryGirl.create :oauth_provider, name: 'facebook' }
  let(:oauth_data){ 
    { 
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
    }
  }

  subject{ response }
  describe "GET facebook" do

    before do
      user
      session[:return_to] = return_to
      request.env['omniauth.auth'] = oauth_data
      get :facebook
    end

    context "when there is no such user" do
      let(:user){ nil }
      it{ should redirect_to new_user_registration_url }
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
