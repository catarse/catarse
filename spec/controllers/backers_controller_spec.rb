require 'spec_helper'

describe BackersController do
  subject{ response }
  describe "GET index" do
    let(:backer){ Factory(:backer) }
    before do
      get :index, :user_id => backer.user.id, :locale => 'pt', :format => 'json'
    end
    its(:status){ should == 200 }
    its(:body){ should == [backer].to_json({:include_project => true, :include_reward => true}) }
  end

end
