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
      @unsubscribe = Factory(:unsubscribe, user_id: user.id)
      @project = Factory(:project)
      @notification_type = Factory(:notification_type)
      post :create, project_id: @project.id, locale: 'pt', user_id: user.id, notification_type_id: @notification_type.id
      it{ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 1 }
      post :create, project_id: @project.id, locale: 'pt', user_id: user.id, notification_type_id: @notification_type.id
      it{ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 0 }
    end
  end

end
