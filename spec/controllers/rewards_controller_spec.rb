require 'rails_helper'

RSpec.describe RewardsController, type: :controller do
  subject{ response }
  let(:project){ create(:project) }
  let(:reward){ create(:reward, project: project) }
  let(:user){ nil }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST sort" do
    before do
      post :sort, project_id: project.id, id: reward.id, reward: {row_order_position: 1}, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner" do
      let(:user){ project.user }
      it{ is_expected.to be_successful }
    end
  end

end
