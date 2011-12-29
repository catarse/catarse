#encoding:utf-8
require 'spec_helper'

describe PostsController do
  render_views
  subject{ response }

  describe "POST create" do
    let(:project){ Factory(:project) }
    context "success" do
      before{
        Post.any_instance.stubs(:save).returns(true)
        post :create, post: {project_id: project.id, body: 'body', title: 'title'}
      }

      it{ should redirect_to(controller: :projects, action: :show, id: project.to_param, :anchor => 'updates') }
    end
  end
end