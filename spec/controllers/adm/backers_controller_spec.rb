require 'spec_helper'

describe Adm::BackersController do
  subject{ response }
  let(:admin) do 
    u = Factory(:user)
    u.admin = true
    u.save!
    u
  end

  describe "GET index" do
    context "when I'm not logged in" do
      before do
        get :index, :locale => :pt
      end
      it{ should redirect_to login_path }
    end

    context "when I'm logged as admin" do
      before do
        controller.stubs(:current_user).returns(admin)
        get :index, :locale => :pt
      end
      its(:status){ should == 200 }
    end
  end

  describe ".menu" do
    it "should add a menu entry to the menu_items class variable when we pass a parameter and retrieve when we have no parameters" do
      Adm::BackersController.menu "Test Menu" => "/path"
      Adm::BaseController.menu.should include("Test Menu")
    end
  end
end
