require 'spec_helper'

describe BackersController do
  subject{ response }
  let(:backer){ Factory(:backer) }
  before{ Notification.stubs(:notify_project_owner) }
  before{ Notification.stubs(:notify_backer) }
  describe "GET index" do
    context "when user can not manage the profile or is anonymous" do
      before do
        get :index, :user_id => backer.user.id, :locale => 'pt', :format => 'json'
      end
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({:include_project => true, :can_manage => false}) }
    end

    context "when user can manage the profile" do
      before do
        controller.session[:user_id] = backer.user.id
        get :index, :user_id => backer.user.id, :locale => 'pt', :format => 'json'
      end
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({:include_project => true, :can_manage => true}) }
    end
  end

end
