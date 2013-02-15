require 'spec_helper'

describe BackersController do
  subject{ response }
  let(:project){ FactoryGirl.create(:project, :finished => true) }
  let(:backer){ FactoryGirl.create(:backer, :project => project) }
  let(:user){ nil }
  let(:format){ 'json' }
  before do
    ::Configuration[:base_url] = 'http://catarse.me'
    controller.stubs(:current_user).returns(user)
    get :index, :user_id => backer.user.id, :locale => 'pt', :format => format
  end

  describe "GET index" do
    context "when format is html" do
      let(:format){ 'html' }
      its(:status){ should == 404 }
    end

    context "when user can not manage the profile or is anonymous" do
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({:include_project => true, :can_manage => false}) }
    end

    context "when user can manage the profile" do
      let(:user){ backer.user }
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({:include_project => true, :can_manage => true}) }
    end
  end
end
