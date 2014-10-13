require 'rails_helper'

RSpec.describe RewardsController, type: :controller do
  subject{ response }
  let(:project) { FactoryGirl.create(:project) }
  let(:reward) { FactoryGirl.create(:reward, project: project) }

  shared_examples_for "GET rewards index" do
    before { get :index, project_id: project.id, locale: :pt }
    it { is_expected.to be_success }
  end

  shared_examples_for "POST rewards create" do
    before { post :create, project_id: project.id, reward: { description: 'Lorem ipsum', minimum_value: 10, deliver_at: DateTime.now }, locale: :pt }
    it { expect(project.rewards).not_to be_empty}
  end

  shared_examples_for "POST rewards create without permission" do
    before { post :create, project_id: project.id, reward: { description: 'Lorem ipsum', minimum_value: 10, deliver_at: DateTime.now }, locale: :pt }
    it { expect(project.rewards).to be_empty}
  end

  shared_examples_for "PUT rewards update" do
    before { put :update, project_id: project.id, id: reward.id, reward: { description: 'Amenori ipsum' }, locale: :pt }
    it {
      reward.reload
      expect(reward.description).to eq('Amenori ipsum')
    }
  end

  shared_examples_for "PUT rewards update without permission" do
    before { put :update, project_id: project.id, id: reward.id, reward: { description: 'Amenori ipsum' }, locale: :pt }
    it {
      reward.reload
      expect(reward.description).to eq('Foo bar')
    }
  end

  shared_examples_for "DELETE rewards destroy" do
    before { delete :destroy, project_id: project.id, id: reward.id, locale: :pt }
    it { expect(project.rewards).to be_empty}
  end

  shared_examples_for "DELETE rewards destroy without permission" do
    before { delete :destroy, project_id: project.id, id: reward.id, locale: :pt }
    it { expect(project.rewards).not_to be_empty}
  end

  context "When current_user is a guest" do
    before { allow(controller).to receive(:current_user).and_return(nil) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create without permission"
    it_should_behave_like "PUT rewards update without permission"
    it_should_behave_like "DELETE rewards destroy without permission"
  end

  context "When current_user is a project owner" do
    before { allow(controller).to receive(:current_user).and_return(project.user) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create"
    it_should_behave_like "PUT rewards update"
    it_should_behave_like "DELETE rewards destroy"

    context "When reward already have contributions" do
      before { FactoryGirl.create(:contribution, state: 'confirmed', project: project, reward: reward) }

      context "can't update the minimum value" do
        before { put :update, project_id: project.id, id: reward.id, reward: { minimum_value: 15, description: 'Amenori ipsum' }, locale: :pt }
        it {
          reward.reload
          expect(reward.minimum_value).not_to eq(15.0)
        }
      end

      context "can update the description and maximum contributions" do
        before do
          put :update, project_id: project.id, id: reward.id, reward: { maximum_contributions: 99, description: 'lorem ipsum'}, locale: :pt
          reward.reload
        end

        it { expect(reward.description).to eq('lorem ipsum') }
        it { expect(reward.maximum_contributions).to eq(99) }
      end

    end
  end

  context "when current_user is admin" do
    before { allow(controller).to receive(:current_user).and_return(FactoryGirl.create(:user, admin: true))}

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create"
    it_should_behave_like "PUT rewards update"
    it_should_behave_like "DELETE rewards destroy"
  end

  context "When current_user is a registered user" do
    before { allow(controller).to receive(:current_user).and_return(FactoryGirl.create(:user)) }

    it_should_behave_like "GET rewards index"
    it_should_behave_like "POST rewards create without permission"
    it_should_behave_like "PUT rewards update without permission"
    it_should_behave_like "DELETE rewards destroy without permission"
  end
end
