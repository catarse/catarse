require 'spec_helper'

describe Admin::StatisticsController do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  before do
    controller.stub(:current_user).and_return(admin)
  end

  describe "GET index" do
    before do
      get :index, locale: 'pt'
    end
    it{ should render_template :index }
    its(:status){ should == 200 }
  end
end
