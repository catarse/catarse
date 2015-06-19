require 'rails_helper'

RSpec.describe BankAccountsController, type: :controller do
  subject{ response }
  let(:project) { create(:project, state: 'online', goal: 1000 )}
  let(:user){ create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET new" do
    context "when user does not have pending refund payments" do
      before do
        get :new, locale: :pt
      end
      it{ is_expected.to redirect_to root_path }
    end

    context "when user have pending refund payments" do
      let(:contribution) do
        create(:confirmed_contribution, {
          project: project,
          value: 10,
          user: user
        })
      end

      before do
        payment = contribution.payments.first
        payment.update_column(:gateway, 'Pagarme')
        project.update_column(:state, 'failed')
      end

      context "when user have a bank_account" do
        before { get :new, locale: :pt }
        it "should redirect to bank_account edit" do
          is_expected.to redirect_to edit_bank_account_path(user.bank_account)
        end
      end

      context "when user not have a bank_account" do
        let(:user) { create(:user, bank_account: nil) }

        before do
          get :new, locale: :pt
        end
        it "should render new form" do
          is_expected.to have_http_status(200)
        end
      end
    end
  end
end

