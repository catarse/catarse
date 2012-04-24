require 'spec_helper'

describe UpdatesController do
  subject{ response }
  describe "GET index" do
    before do
      @update = Factory(:update)
      get :index, :project_id => @update.project.id, :locale => 'pt', :format => 'json'
    end
    its(:status){ should == 200 }
    its(:body){ should == [@update].to_json }
  end

  describe "POST create" do
    before do
      
    end
  
  end

end
