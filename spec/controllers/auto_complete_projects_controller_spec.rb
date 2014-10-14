#encoding:utf-8
require 'rails_helper'

RSpec.describe AutoCompleteProjectsController, type: :controller do
  render_views
  subject{ response }

  describe "GET index" do
    context "search_on_name param" do
      before do
        @project_01 = create(:project, name: 'lorem dolor')
        @project_02 = create(:project, name: 'lorem ipsum')
        @project_03 = create(:project, name: 'Dolor')

        get :index, locale: :pt, search_on_name: 'lorem'
      end

      it { expect(assigns(:projects)).to eq([@project_01, @project_02]) }
    end
  end

end
