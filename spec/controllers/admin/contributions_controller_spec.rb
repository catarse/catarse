require 'spec_helper'

describe Admin::ContributionsController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:unconfirmed_contribution) { create(:contribution) }
  let(:current_user){ admin }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  describe 'PUT confirm' do
    let(:contribution) { create(:contribution) }
    subject { contribution.confirmed? }

    before do
      put :confirm, id: contribution.id, locale: :pt
    end

    it do
      contribution.reload
      should be_true
    end
  end

  describe 'PUT push_to_trash' do
    let(:contribution) { create(:contribution, state: 'pending') }
    subject { contribution.deleted? }

    before do
      put :push_to_trash, id: contribution.id, locale: :pt
      contribution.reload
    end

    it { should be_true }
  end

  describe 'PUT hide' do
    let(:contribution) { create(:contribution, state: 'confirmed') }
    subject { contribution.refunded_and_canceled? }

    before do
      controller.stub(:current_user).and_return(admin)
      put :hide, id: contribution.id, locale: :pt
    end

    it do
      contribution.reload
      should be_true
    end
  end

  describe 'PUT refund' do
    let(:contribution) { create(:contribution, state: 'confirmed') }
    subject { contribution.refunded? }

    before do
      put :refund, id: contribution.id, locale: :pt
    end

    it do
      contribution.reload
      should be_true
    end
  end

  describe 'PUT pendent' do
    let(:contribution) { create(:contribution, state: 'confirmed') }
    subject { contribution.confirmed? }

    before do
      put :pendent, id: contribution.id, locale: :pt
    end

    it do
      contribution.reload
      should be_false
    end
  end

  describe 'PUT cancel' do
    let(:contribution) { create(:contribution, state: 'confirmed') }
    subject { contribution.canceled? }

    before do
      put :cancel, id: contribution.id, locale: :pt
    end

    it do
      contribution.reload
      should be_true
    end
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ should redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, locale: :pt
      end
      its(:status){ should == 200 }
    end
  end

  describe '.collection' do
    let(:contribution) { create(:contribution, payer_email: 'foo@foo.com') }
    context "when there is a match" do
      before do
        get :index, locale: :pt, payer_email_contains: 'foo@foo.com'
      end
      it{ assigns(:contributions).should eq([contribution]) }
    end

    context "when there is no match" do
      before do
        get :index, locale: :pt, payer_email_contains: '2foo@foo.com'
      end
      it{ assigns(:contributions).should eq([]) }
    end
  end
end
