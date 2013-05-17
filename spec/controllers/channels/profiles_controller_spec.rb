require 'spec_helper'

describe Channels::ProfilesController do
  subject{ response }
  let(:channel){ FactoryGirl.create(:channel) }

  describe "GET show" do
    before do
      request.stub(:subdomain).and_return(channel.permalink)
      get :show, id: 'sample'
    end

    its(:status){ should == 200 }
  end
end

