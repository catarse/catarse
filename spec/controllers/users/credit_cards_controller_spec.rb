require 'rails_helper'

RSpec.describe Users::CreditCardsController, type: :controller do
  subject{ response }
  let(:user){ create(:user) }
  let(:credit_card){ create(:credit_card, user: user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "DELETE destroy" do
    before do
      delete :destroy, user_id: user.id, id: credit_card.id, locale: :pt
    end

    context "when user is card owner" do
      its(:status) { should == 302 }
    end
  end

end
