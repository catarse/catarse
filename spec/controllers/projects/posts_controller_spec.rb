require 'rails_helper'

RSpec.describe Projects::PostsController, type: :controller do
  let(:project_post){ FactoryGirl.create(:project_post) }
  let(:current_user){ nil }
  before{ allow(controller).to receive(:current_user).and_return(current_user) }
  subject{ response }

  describe "GET index" do
    before{ get :index, project_id: project_post.project.id, locale: 'pt', format: 'html' }
    its(:status){ should == 200 }
  end
end
