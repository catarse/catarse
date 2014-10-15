require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user){ admin }
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, locale: :pt
      end
      its(:status){ should == 200 }
    end
  end

end

