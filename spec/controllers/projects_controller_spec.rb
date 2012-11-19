#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  before {Notification.unstub(:create_notification)}
  render_views
  subject{ response }

  describe "GET show" do
    context "when we have update_id in the querystring" do
      let(:project){ Factory(:project, :permalink => nil) }
      let(:update){ Factory(:update, :project => project) }
      before{ get :show, :id => project, :update_id => update.id, :locale => :pt }
      it("should assign update to @update"){ assigns(:update).should == update }
    end

    context "when we have permalink and do not pass permalink in the querystring" do
      let(:project){ Factory(:project, :permalink => 'test') }
      before{ get :show, :id => project, :locale => :pt }
      it{ should redirect_to project_by_slug_path(project.permalink) }
    end

    context "when we do not have permalink and do not pass permalink in the querystring" do
      let(:project){ Factory(:project, :permalink => nil) }
      before{ get :show, :id => project, :locale => :pt }
      it{ should be_success }
    end
  end

  describe "POST send_mail" do
    let(:project){ Factory(:project) }
    Factory(:notification_type, :name => 'project_received')
    let(:name){ project.name }
    let(:user){ project.user }

    before do
      controller.stubs(:current_user).returns(user)
      Notification.expects(:create_notification).with(:project_received, user)
      post :send_mail, :locale => :pt
    end

    it{ should redirect_to root_path }
  end
end
