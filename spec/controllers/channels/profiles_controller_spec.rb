require 'spec_helper'

describe Channels::ProfilesController do
  subject{ response }
  let(:channel){ FactoryGirl.create(:channel) }

  describe "GET show" do
    before do
      request.stubs(:subdomain).returns(channel.permalink)
      get :show, id: 'sample'
    end

    its(:status){ should == 200 }
  end
end

