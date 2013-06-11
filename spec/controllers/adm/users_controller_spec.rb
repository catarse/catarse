require 'spec_helper'

describe Adm::UsersController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }

  describe "GET index" do
    context "when I'm not logged in" do
      before do
        get :index, :locale => :pt
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        controller.stub(:current_user).and_return(admin)
        get :index, :locale => :pt
      end
      its(:status){ should == 200 }
    end
  end

end

