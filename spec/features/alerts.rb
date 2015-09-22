# coding: utf-8

require 'rails_helper'

RSpec.describe "Alerts", type: :feature do
  let(:project) { create(:project) }
  describe "pending refunds top alert" do
    context "when not have logged user" do
      it "should not have pending refund alert" do
        visit root_path(locale: :pt)
        sleep FeatureHelpers::TIME_TO_SLEEP
        expect(page).to_not have_content(I18n.t("shared.alerts.pending_payment_link_text"))
      end
    end

    context "when user is logged" do
      context "and have pending_refund payments" do
        before do
          login
          c = create(:confirmed_contribution, value: 10, user: current_user, project: project)
          payment = c.payments.first
          payment.update_column(:payment_method, 'BoletoBancario')
          project.update_column(:state, 'failed')
          project.reload
          current_user.reload
          visit root_path(locale: :pt)
        end

        it "should show a alert" do
          sleep FeatureHelpers::TIME_TO_SLEEP
          expect(page).to have_content(I18n.t("shared.alerts.pending_payment_link_text"))
        end
      end

      context "and not have pending_refund payments" do
        it "should not show a alert" do
          login
          visit root_path(locale: :pt)
          sleep FeatureHelpers::TIME_TO_SLEEP
          expect(page).to_not have_content(I18n.t("shared.alerts.pending_payment_link_text"))
        end
      end
    end
  end
end
