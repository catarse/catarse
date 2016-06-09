require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  subject{ response }

  let(:user) { create(:user) }
  let(:project_notification) { create(:project_notification, user: user) }
  let(:current_user) { user }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    project_notification
  end

  describe "#show" do

    context "when user is not authenticated" do
      let(:current_user) { nil }
      before do
        get :show, notification_type: 'project_notification', notification_id: project_notification.id
      end

      it { is_expected.to_not be_successful }
    end

    context "when user is authenticated" do
      context "when requesting self notification" do
        before do
          get :show, notification_type: 'project_notification', notification_id: project_notification.id
        end

        it { is_expected.to be_successful }
      end

      context "when requesting somone else notification" do
        let(:current_user) { create(:user) }
        before do
          get :show, notification_type: 'project_notification', notification_id: project_notification.id
        end

        it { is_expected.to_not be_successful }
      end

      context "when requesting somone else notification has admin" do
        let(:current_user) { create(:user, admin: true) }
        before do
          get :show, notification_type: 'project_notification', notification_id: project_notification.id
        end

        it { is_expected.to be_successful }
      end
    end
  end
end
