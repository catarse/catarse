require 'spec_helper'

describe UnsubscribesController do
  subject{ response }

  describe "GET index" do
    before do
      Factory(:notification_type, name: 'updates')
      @unsubscribe = Factory(:unsubscribe)
      get :index, user_id: @unsubscribe.user.id, locale: 'pt', format: 'json'
    end
    its(:status){ should == 200 }
  end

  describe "POST create" do
    let(:user){ Factory(:user) }
    before do
      request.session[:user_id] = user.id
      @project = Factory(:project)
      @notification_type = Factory(:notification_type)
    end

    context "when we already have such unsubscribe" do
      before do
        Factory(:unsubscribe, project_id: @project.id, user_id: user.id, notification_type_id: @notification_type.id)
        post :create, project_id: @project.id, locale: 'pt', user_id: user.id, notification_type_id: @notification_type.id
      end
      its(:status){ should == 200 }
      it("should destroy the unsubscribe"){ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 0 }
    end

    context "when we do not have such unsubscribe" do
      before do
        post :create, project_id: @project.id, locale: 'pt', user_id: user.id, notification_type_id: @notification_type.id
      end
      its(:status){ should == 200 }
      it("should create an unsubscribe"){ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 1 }
    end
  end

end
