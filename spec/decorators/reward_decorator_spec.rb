require 'rails_helper'

RSpec.describe RewardDecorator do
  include ActionView::Helpers::NumberHelper

  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com') }

  describe "#display_description" do
    subject{ reward.display_description }
    it{ is_expected.to eq("<p>envie um email para foo@bar.com</p>") }
  end

  describe "#display_minimum" do
    subject{ reward.display_minimum }
    it{ is_expected.to eq(number_to_currency(reward.minimum_value)) }
  end

  it "should have a HTML-safe name that is a HTML composition from minimum_value, description and sold_out" do
    I18n.locale = :pt
    r = build(:reward, minimum_value: 0, description: "Description<javascript>XSS()</javascript>", maximum_contributions: 0)
    expect(r.name).to include('Description&lt;javascript&gt;XSS()&lt;/javascript&gt;')
  end
end
