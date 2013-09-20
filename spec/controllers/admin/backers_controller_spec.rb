require 'spec_helper'

describe Adm::BackersController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:unconfirmed_backer) { create(:backer) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'PUT confirm' do
    let(:backer) { create(:backer) }
    subject { backer.confirmed? }

    before do
      put :confirm, id: backer.id, locale: :pt 
    end

    it do
      backer.reload
      should be_true
    end
  end

  describe 'PUT push_to_trash' do
    let(:backer) { create(:backer, state: 'pending') }
    subject { backer.deleted? }

    before do
      put :push_to_trash, id: backer.id, locale: :pt
      backer.reload
    end

    it { should be_true }
  end

  describe 'PUT hide' do
    let(:backer) { create(:backer, state: 'confirmed') }
    subject { backer.refunded_and_canceled? }

    before do
      controller.stub(:current_user).and_return(admin)
      put :hide, id: backer.id, locale: :pt
    end

    it do
      backer.reload
      should be_true
    end
  end

  describe 'PUT refund' do
    let(:backer) { create(:backer, state: 'confirmed') }
    subject { backer.refunded? }

    before do
      put :refund, id: backer.id, locale: :pt 
    end

    it do
      backer.reload
      should be_true
    end
  end

  describe 'PUT pendent' do
    let(:backer) { create(:backer, state: 'confirmed') }
    subject { backer.confirmed? }

    before do
      put :pendent, id: backer.id, locale: :pt 
    end

    it do
      backer.reload
      should be_false
    end
  end

  describe 'PUT cancel' do
    let(:backer) { create(:backer, state: 'confirmed') }
    subject { backer.canceled? }

    before do
      put :cancel, id: backer.id, locale: :pt 
    end

    it do
      backer.reload
      should be_true
    end
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, :locale => :pt
      end
      it{ should redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
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
