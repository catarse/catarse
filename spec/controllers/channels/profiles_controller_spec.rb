require 'rails_helper'

RSpec.describe Channels::ProfilesController, type: :controller do
  subject{ response }
  let(:channel){ FactoryGirl.create(:channel) }

  describe "GET show" do
    before do
      allow(request).to receive(:subdomain).and_return(channel.permalink)
      get :show, id: 'sample'
    end

    its(:status){ should == 200 }
  end
end

