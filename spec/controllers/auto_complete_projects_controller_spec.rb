#encoding:utf-8
require 'rails_helper'

RSpec.describe AutoCompleteProjectsController, type: :controller do
  render_views
  subject{ response }

  describe "GET index" do
    context "pg_search param" do
      before do
        @project_01 = create(:project, name: 'lorem dolor')
        @project_02 = create(:project, name: 'lorem ipsum')
        @project_03 = create(:project, name: 'Dolor')

        get :index, locale: :pt, pg_search: 'lorem'
      end

      it { expect(assigns(:projects)).to eq([@project_01, @project_02]) }
    end
  end

end
