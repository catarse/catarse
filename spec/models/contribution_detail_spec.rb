require 'rails_helper'

RSpec.describe ContributionDetail, type: :model do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :reward }
    it{ should belong_to :contribution }
    it{ should belong_to :payment }
  end

  describe ".between_values" do
    let(:start_at) { 10 }
    let(:ends_at) { 20 }
    subject { ContributionDetail.between_values(start_at, ends_at) }
    before do
      create(:confirmed_contribution, value: 10)
      create(:confirmed_contribution, value: 15)
      create(:confirmed_contribution, value: 20)
      create(:confirmed_contribution, value: 21)
    end
    it { is_expected.to have(3).itens }
  end

end
