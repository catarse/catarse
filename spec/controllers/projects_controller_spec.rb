#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  render_views
  subject{ response }

  describe "GET show" do
    let(:project){ Factory(:project, permalink: nil) }
    before{ get :show, :id => project, :locale => :pt }
    it{ should be_success }
  end

  context "should redirect to /slug when project that already have a slug" do
    it {
      project = Factory(:project, permalink: 'perma')
      get :show, :id => project, :locale => :pt
      should be_redirect
    }
  end
end
