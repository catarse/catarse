require 'rails_helper'

RSpec.describe RewardsController, type: :controller do
  subject{ response }
  let(:project){ create(:project) }
  let(:reward){ create(:reward, project: project) }
  let(:user){ nil }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET index" do
    before do
      get :index, project_id: project.id, locale: :pt
    end
    it{ is_expected.to be_successful }
  end

  describe "GET new" do
    before do
      get :new, project_id: project.id, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner" do
      let(:user){ project.user }
      it{ is_expected.to be_successful }
      it{ is_expected.to render_template('rewards/_form') }
    end
  end

  describe "GET edit" do
    before do
      get :edit, project_id: project.id, id: reward.id, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner" do
      let(:user){ project.user }
      it{ is_expected.to be_successful }
      it{ is_expected.to render_template('rewards/_form') }
    end
  end

  describe "PATCH update" do
    let(:reward_attributes){ nil }
    before do
      patch :update, project_id: project.id, id: reward.id, reward: reward_attributes, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner and update works" do
      let(:user){ project.user }
      its(:status){ should == 302 }
    end

    context "when user is project owner and update fails" do
      let(:user){ project.user }
      let(:reward_attributes){ {minimum_value: 0} }
      it{ is_expected.to be_successful }
      it{ is_expected.to render_template('rewards/_form') }
    end
  end

  describe "POST create" do
    let(:reward_attributes){ {minimum_value: 10, description: 'foo bar', deliver_at: Time.now + 1.day} }
    before do
      post :create, project_id: project.id, reward: reward_attributes, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner and create works" do
      let(:user){ project.user }
      its(:status){ should == 302 }
    end

    context "when user is project owner and create fails" do
      let(:user){ project.user }
      let(:reward_attributes){ {minimum_value: 0, deliver_at: Time.now + 1.day} }
      it{ is_expected.to be_successful }
      it{ is_expected.to render_template('rewards/_form') }
    end
  end

  describe "DELETE destroy" do
    before do
      delete :destroy, project_id: project.id, id: reward.id, locale: :pt
    end

    context "when user is not logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user is project owner and delete works" do
      let(:user){ project.user }
      it{ is_expected.to redirect_to edit_project_path(project, anchor: 'reward') }
    end
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
