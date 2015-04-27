require 'rails_helper'

RSpec.describe Projects::ContributionDetailsController, type: :controller do
  let(:project) { create(:project) }
  let(:contribution){ create(:pending_contribution, value: 10.00, project: project) }
  let(:user){ nil }

  subject{ response }

  describe "GET index" do
    before do
      create(:confirmed_contribution, value: 10.00,
              reward: create(:reward, project: project, description: 'Test Reward'),
              project: project,
              user: create(:user, name: 'Foo Bar'))
      get :index, { locale: :pt, project_id: project.id }
    end
    it{ is_expected.to be_successful }
  end
end
