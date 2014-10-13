#encoding:utf-8
require 'spec_helper'

describe AutoCompleteProjectsController do
  render_views
  subject{ response }

  describe "GET index" do
    before do
      controller.stub(:last_tweets).and_return([])
      get :index, locale: :pt
    end
    it { should be_success }

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
