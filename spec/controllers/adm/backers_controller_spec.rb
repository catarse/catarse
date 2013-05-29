require 'spec_helper'

describe Adm::BackersController do
  subject{ response }
  let(:admin) { FactoryGirl.create(:user, admin: true) }

  let(:unconfirmed_backer) { FactoryGirl.create(:backer) }

  describe 'PUT confirm' do
    let(:backer) { FactoryGirl.create(:backer) }
    subject { backer.confirmed? }

    before { 
      controller.stub(:current_user).and_return(admin)
      put :confirm, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_true
    }
  end

  describe 'PUT hide' do
    let(:backer) { FactoryGirl.create(:backer, state: 'confirmed') }
    subject { backer.refunded_and_canceled? }

    before {
      controller.stub(:current_user).and_return(admin)
      put :hide, id: backer.id, locale: :pt
    }

    it {
      backer.reload
      should be_true
    }
  end

  describe 'PUT refund' do
    let(:backer) { FactoryGirl.create(:backer, state: 'confirmed') }
    subject { backer.refunded? }

    before { 
      controller.stub(:current_user).and_return(admin)
      put :refund, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_true
    }    
  end

  describe 'PUT pendent' do
    let(:backer) { FactoryGirl.create(:backer, state: 'confirmed') }
    subject { backer.confirmed? }

    before { 
      controller.stub(:current_user).and_return(admin)
      put :pendent, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_false
    }
  end

  describe 'PUT cancel' do
    let(:backer) { FactoryGirl.create(:backer, state: 'confirmed') }
    subject { backer.canceled? }

    before {
      controller.stub(:current_user).and_return(admin)
      put :cancel, id: backer.id, locale: :pt 
    }

    it {
      backer.reload
      should be_true
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
        controller.stub(:current_user).and_return(admin)
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
