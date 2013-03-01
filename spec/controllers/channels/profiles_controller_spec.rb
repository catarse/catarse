require 'spec_helper'

describe Channels::ProfilesController do

  describe "GET #index" do
    it "returns http success/moved temporarily" do
      get :index
      response.status.should == 302 
    end
  end

end

