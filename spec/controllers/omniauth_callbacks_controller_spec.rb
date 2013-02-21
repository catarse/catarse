require 'spec_helper'

describe OmniauthCallbacksController do
  subject{ response }
  describe "GET facebook" do
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
    before do
      user
      request.env['omniauth.auth'] = oauth_data
      get :facebook
    end

    context "when there is a valid user with this provider and uid and session return_to is nil" do
      it{ assigns(:user).should == user }
      it{ should redirect_to root_path }
    end
  end
end
