require 'rails_helper'

RSpec.describe Categories::SubscriptionsController, type: :controller do
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  subject{ response }

  let(:category) { create(:category) }
  let(:current_user) { nil }

  describe "GET create" do
    context "when user not logged in" do
      before do
        get :create, id: category.id, locale: :pt
      end

      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context "with user" do
      let(:current_user) { create(:user) }

      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        get :create, id: category.id, locale: :pt
        current_user.reload
      end

      it { expect(current_user.following_this_category?(category.id)).to be(true) }
    end

    context "with user already subscribed" do
      let(:current_user) { create(:user) }

      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        category.users << current_user
        current_user.reload
      end

      it do
        expect {
          get :create, id: category.id, locale: :pt
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "GET destroy" do
      context "when user not logged in" do
        before do
          get :destroy, id: category.id, locale: :pt
        end

        it { is_expected.to redirect_to(new_user_session_path) }
      end

      context "with user" do
        let(:current_user) { create(:user) }

        before do
          allow(controller).to receive(:authenticate_user!).and_return(true)
          get :destroy, id: category.id, locale: :pt
        end

        it { expect(current_user.following_this_category?(category.id)).to be(false) }
      end

      context "with user already subscribed" do
        let(:current_user) { create(:user) }

        before do
          allow(controller).to receive(:authenticate_user!).and_return(true)
          category.users << current_user
          get :destroy, id: category.id, locale: :pt
          current_user.reload
        end

        it { expect(current_user.following_this_category?(category.id)).to be(false) }
      end
    end
  end

end
