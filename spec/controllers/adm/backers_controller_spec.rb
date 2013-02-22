require 'spec_helper'

describe Adm::BackersController do
  subject{ response }
  let(:admin) do 
    u = FactoryGirl.create(:user)
    u.admin = true
    u.save!
    u
  end

  let(:unconfirmed_backer) do
    b = FactoryGirl.create(:backer)
    b.confirmed = false
    b.save!
    b
  end

  describe 'PUT confirm' do
    let(:backer) { FactoryGirl.create(:backer, confirmed: false) }
    subject { backer.confirmed }

    before { 
      controller.stubs(:current_user).returns(admin)
      put :confirm, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_true
    }
  end

  describe 'PUT unconfirm' do
    let(:backer) { FactoryGirl.create(:backer, confirmed: true) }
    subject { backer.confirmed }

    before { 
      controller.stubs(:current_user).returns(admin)
      put :unconfirm, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_false
    }
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

  describe ".menu" do
    it "should add a menu entry to the menu_items class variable when we pass a parameter and retrieve when we have no parameters" do
      Adm::BackersController.menu "Test Menu" => "/path"
      Adm::BaseController.menu.should include("Test Menu")
    end
  end
end
