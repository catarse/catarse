require 'rails_helper'


RSpec.describe BankAccountsController, type: :controller do
  subject{ response }
  let(:project) { create(:project, state: 'online', goal: 1000 )}
  let(:user){ create(:user) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET edit" do
    let(:bank_account_id) do
      user.try(:bank_account).try(:id)
    end

    context "when user does not logged in" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:authenticate_user!).and_call_original
        get :edit, locale: :pt, id: bank_account_id
      end

      it{ is_expected.to redirect_to new_user_session_path }
    end

    context "when user does not have pending refund payments" do
      before do
        get :edit, locale: :pt, id: bank_account_id
      end
      it{ is_expected.to redirect_to root_path}
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
        get :edit, locale: :pt, id: bank_account_id
      end

      it "should render form" do
        is_expected.to render_template(:edit)
      end
    end
  end

  describe "GET new" do
    context "when user does not logged in" do
      before do
        allow(controller).to receive(:authenticate_user!).and_call_original
        get :new, locale: :pt
      end

      it{ is_expected.to redirect_to new_user_session_path }
    end

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
        it "should render form" do
          is_expected.to render_template(:edit)
        end
      end
    end
  end

  describe "POST create" do
    context "when user does not logged in" do
      before do
        allow(controller).to receive(:authenticate_user!).and_call_original
        post :create, locale: :pt
      end

      it{ is_expected.to redirect_to new_user_session_path }
    end

    context "when user does not have pending refund payments" do
      before do
        post :create, locale: :pt
      end
      it{ is_expected.to redirect_to root_path }
    end

    context "when user have pending refund payments" do
      let(:bank) { create(:bank) }
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

      let(:user) { create(:user, bank_account: nil) }

      before do
        post :create, {
          locale: :pt,
          bank_account: {
            bank_id: bank.id,
            owner_name: "Foo Bar",
            owner_document: "97666238991",
            account_digit: "1",
            agency: "1",
            agency_digit: "1",
            account: "1"
          }
        }
      end

      it "should redirect to confirm" do
        is_expected.to redirect_to confirm_bank_account_path(user.bank_account)
      end
    end
  end

  describe "PUT update" do
    context "when user does not logged in" do
      let(:user) { create(:user) }
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:authenticate_user!).and_call_original
        put :update, locale: :pt, id: user.bank_account.id
      end

      it{ is_expected.to redirect_to new_user_session_path }
    end

    context "when user does not have pending refund payments" do
      let(:user) { create(:user) }
      before do
        put :update, locale: :pt, id: user.bank_account.id
      end
      it{ is_expected.to redirect_to root_path }
    end

    context "when user have pending refund payments" do
      let(:bank) { create(:bank) }
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

      before do
        put :update, {
          locale: :pt,
          id: user.bank_account.id,
          bank_account: {
            owner_name: "Foo Bar 2",
          }
        }
        user.bank_account.reload
      end

      it "should update bank_account" do
        expect(user.bank_account.owner_name).to eq("Foo Bar 2")
      end

      it "should redirect to confirm" do
        is_expected.to redirect_to confirm_bank_account_path(user.bank_account)
      end
    end
  end

  describe "PUT request_refund" do
    context "when user does not logged in" do
      let(:user) { create(:user) }
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:authenticate_user!).and_call_original
        put :request_refund, locale: :pt, id: user.bank_account.id
      end

      it{ is_expected.to redirect_to new_user_session_path }
    end

    context "when user does not have pending refund payments" do
      let(:user) { create(:user) }
      before do
        put :request_refund, locale: :pt, id: user.bank_account.id
      end
      it{ is_expected.to redirect_to root_path }
    end

    context "when user have pending refund payments" do
      let(:bank) { create(:bank) }
      let(:payment) do
        payment = create(:confirmed_contribution, {
          project: project,
          value: 10,
          user: user
        }).payments.first
        payment.update_column(:gateway, 'Pagarme')
        payment
      end

      before do
        Sidekiq::Testing.inline!
        expect(DirectRefundWorker).to receive(:perform_async).with(payment.id)
        project.update_column(:state, 'failed')

        put :request_refund, {
          locale: :pt,
          id: user.bank_account.id
        }
      end

      it "should redirect to success" do
        is_expected.to redirect_to bank_account_path(user.bank_account)
      end
    end
  end


end

