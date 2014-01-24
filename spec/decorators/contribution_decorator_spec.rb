require 'spec_helper'

describe ContributionDecorator do
  before do
    I18n.locale = :pt
  end

  describe "#display_confirmed_at" do
    subject{ contribution.display_confirmed_at }
    context "when confirmet_at is not nil" do
      let(:contribution){ build(:contribution, confirmed_at: Time.now) }
      it{ should == I18n.l(contribution.confirmed_at.to_date) }
    end

    context "when confirmet_at is nil" do
      let(:contribution){ build(:contribution, confirmed_at: nil) }
      it{ should be_nil }
    end
  end

  describe "#display_value" do

    context "when the value has decimal places" do
      subject{ build(:contribution, value: 99.99).display_value }
      it{ should == "R$ 100" }
    end

    context "when the value does not have decimal places" do
      subject{ build(:contribution, value: 1).display_value }
      it{ should == "R$ 1" }
    end
  end
end

