require 'rails_helper'

RSpec.describe BankAccountsController, type: :controller do
  subject{ response }
  let(:user){ create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET new" do
    before do
      get :new
    end

    context "when user does not have pending refunds" do
      it{ is_expected.to redirect_to root_path }
    end
  end
end

