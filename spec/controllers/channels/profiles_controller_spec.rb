require 'spec_helper'

describe Channels::ProfilesController do

  describe "GET #show" do
    it "should return HTTP status 200" do
      get :show, id: 'sample'
      response.code.to_i.should == 302
    end
  end

end

