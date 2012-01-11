#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  render_views
  subject{ response }

  describe "GET show" do
    let(:project){ Factory(:project) }
    before{
      mock_tumblr
      get :show, id: project, locale: :pt
    }

    it{ should be_success }
    context "with posts" do
      its(:body){ should =~ /Belo Monte de Vozes/ }
    end
  end
end