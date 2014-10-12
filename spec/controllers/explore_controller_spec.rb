require 'rails_helper'

RSpec.describe ExploreController, type: :controller do
  subject{ response }
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET index" do
    context "when no user is logged in" do
      let(:user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ is_expected.to be_successful }
    end
  end
end
