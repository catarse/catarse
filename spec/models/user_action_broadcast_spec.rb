require "rails_helper"

RSpec.describe UserActionBroadcast, type: :model do
  let(:user) { create(:user) }
  let(:follower_one) { create(:user) }
  let(:follower_two) { create(:user) }
  let(:project) { create(:project, user: user, state: 'online') }
  let!(:uf1) { create(:user_follow, user_id: follower_one.id, follow_id: user.id) }
  let!(:uf2) { create(:user_follow, user_id: follower_two.id, follow_id: user.id) }
  let!(:uf3) { create(:user_follow, user_id: user.id, follow_id: user.id) } # :O

  before do
    Sidekiq::Testing.inline!
  end

  describe ".broadcast_action" do
    context "when user as made a paid contribution" do
      let(:payment) do
        c = create(:pending_contribution, project: project, user: user)
        c.payments.first
      end
      let(:another_payment) do
        c = create(:pending_contribution, project: project, user: user)
        c.payments.first
      end

      before { payment.pay }

      it "should create user_follow_notifications for user followers" do
        expect(UserFollowNotification.where(template_name: 'follow_contributed_project').count).to eq(2)
        expect(uf1.notifications.count).to eq(1)
        expect(uf2.notifications.count).to eq(1)
        expect(uf3.notifications.count).to eq(0)
      end

      it "when made another paid contribution for same project" do
        expect(UserFollowNotification.where(template_name: 'follow_contributed_project').count).to eq(2)
        another_payment.pay
        expect(UserFollowNotification.where(template_name: 'follow_contributed_project').count).to eq(2)
      end
    end

    context "when user as published a new project" do
      let(:project) { create(:project, user: user, state: 'draft') }
      before do
        project.push_to_online
      end

      it "should create user_follow_notifications for user followers" do
        expect(UserFollowNotification.where(template_name: 'follow_project_online').count).to eq(2)
        expect(uf1.notifications.count).to eq(1)
        expect(uf2.notifications.count).to eq(1)
        expect(uf3.notifications.count).to eq(0)
      end

      it "should not create repeated when same project" do
        expect(UserFollowNotification.where(template_name: 'follow_project_online').count).to eq(2)
        project.project_transitions.destroy_all
        project.update_attributes(state: 'draft')
        project.push_to_online
        expect(UserFollowNotification.where(template_name: 'follow_project_online').count).to eq(2)
      end
    end
  end
end
