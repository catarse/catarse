# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BalanceTransfersController, type: :controller do
  subject { response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user) { admin }
  let(:successful_project) { create(:project, state: 'successful')}

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
    request.env['HTTP_REFERER'] = admin_projects_path
  end

  describe 'POST batch_approve' do
    context "when user has admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        current_user.admin_roles.create!(role_label: 'balance')
        post :batch_approve, {transfer_ids: [balance_transfer.id]}
      end

      it "should be successful" do
        expect(response.code.to_i).to eq(200)
      end

      it "expect balance_transfer to authorized" do
        expect(balance_transfer.state).to eq("authorized")
      end
    end

    context "when user has not admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        post :batch_approve, {transfer_ids: [balance_transfer.id]}
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end

      it "expect balance_transfer to pending" do
        expect(balance_transfer.state).to eq("pending")
      end
    end
  end

  describe 'POST batch_reject' do
    context "when user has admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        current_user.admin_roles.create!(role_label: 'balance')
        post :batch_reject, {transfer_ids: [balance_transfer.id]}
      end

      it "should be successful" do
        expect(response.code.to_i).to eq(200)
      end

      it "expect balance_transfer to rejected" do
        expect(balance_transfer.state).to eq("rejected")
      end
    end

    context "when user has not admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        post :batch_reject, {transfer_ids: [balance_transfer.id]}
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end

      it "expect balance_transfer to pending" do
        expect(balance_transfer.state).to eq("pending")
      end
    end
  end

  describe 'POST batch_manual' do
    context "when user has admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        current_user.admin_roles.create!(role_label: 'balance')
        post :batch_manual, {transfer_ids: [balance_transfer.id]}
      end

      it "should be successful" do
        expect(response.code.to_i).to eq(200)
      end

      it "expect balance_transfer to transferred" do
        expect(balance_transfer.state).to eq("transferred")
      end
    end

    context "when user has not admin roles" do
      let(:balance_transfer) { create(:balance_transfer, project: successful_project)}
      before do
        post :batch_manual, {transfer_ids: [balance_transfer.id]}
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end

      it "expect balance_transfer to pending" do
        expect(balance_transfer.state).to eq("pending")
      end
    end
  end
end
