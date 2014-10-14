require 'rails_helper'

RSpec.describe Admin::StatisticsController, type: :controller do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  before do
    allow(controller).to receive(:current_user).and_return(admin)
  end

  describe "GET index" do
    before do
      get :index, locale: 'pt'
    end
    it{ is_expected.to render_template :index }
    its(:status){ should == 200 }
  end
end
