#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  render_views
  subject{ response }

  before(:each) do
  end

  describe "GET show" do
    let(:project){ Factory(:project) }
    before{
      mock_tumblr
      get :show, id: project, locale: :pt
    }

    context "with posts" do
      it{ should be_success}
      it{ response.body.to_s.should =~ /Belo Monte de Vozes/ }
    end
  end
end