require 'rails_helper'

RSpec.describe Users::ProjectsController, type: :controller do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  subject{ response }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET index" do
    before do
      get :index, { locale: :pt, user_id: project.user_id }
    end
    its(:status){ should eq 200 }
  end
end
