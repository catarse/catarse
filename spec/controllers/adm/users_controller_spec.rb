require 'spec_helper'

describe Adm::UsersController do
  subject{ response }
  let(:admin) do 
    u = FactoryGirl.create(:user)
    u.admin = true
    u.save!
    u
  end

  describe "GET index" do
    context "when I'm not logged in" do
      before do
        get :index, :locale => :pt
      end
      it{ should redirect_to new_user_session_path }
    end

    context "when I'm logged as admin" do
      before do
        controller.stubs(:current_user).returns(admin)
        get :index, :locale => :pt
      end
      its(:status){ should == 200 }
    end
  end

end

