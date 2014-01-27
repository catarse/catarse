require 'spec_helper'

describe ExploreController do
  subject{ response }
  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "GET index" do
    context "when no user is logged in" do
      let(:user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ should be_successful }
    end
  end
end
