require 'rails_helper'

RSpec.describe RewardDecorator do
  include ActionView::Helpers::NumberHelper

  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com') }

  describe "#display_description" do
    subject{ reward.display_description }
    it{ is_expected.to eq("<p>envie um email para <a href=\"mailto:foo@bar.com\" target=\"_blank\">foo@bar.com</a></p>") }
  end

  describe "#display_minimum" do
    subject{ reward.display_minimum }
    it{ is_expected.to eq(number_to_currency(reward.minimum_value)) }
  end

  it "should have a HTML-safe name that is a HTML composition from minimum_value, description and sold_out" do
    I18n.locale = :pt
    r = build(:reward, minimum_value: 0, description: "Description", maximum_contributions: 0)
    expect(r.name).to eq("<div class='reward_minimum_value'>Não quero recompensa</div><div class='reward_description'>Description</div><div class=\"sold_out\">Esgotada</div><div class='clear'></div>")
    r.maximum_contributions = 1
    expect(r.name).to eq("<div class='reward_minimum_value'>Não quero recompensa</div><div class='reward_description'>Description</div><div class='clear'></div>")
    r.minimum_value = 10
    expect(r.name).to eq("<div class='reward_minimum_value'>R$ 10+</div><div class='reward_description'>Description</div><div class='clear'></div>")
    r.description = "Description<javascript>XSS()</javascript>"
    expect(r.name).to eq("<div class='reward_minimum_value'>R$ 10+</div><div class='reward_description'>Description&lt;javascript&gt;XSS()&lt;/javascript&gt;</div><div class='clear'></div>")
  end
end
