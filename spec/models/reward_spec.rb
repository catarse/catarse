# coding: utf-8

require 'spec_helper'

describe Reward do
  let(:reward){ create(:reward, description: 'envie um email para foo@bar.com') }

  describe "Log modifications" do
    describe "when change something" do
      before do
        reward.update_attributes(description: 'foo')
      end

      it "should save the last changes" do
        expect(reward.last_changes).to eq("{\"description\":[\"envie um email para foo@bar.com\",\"foo\"]}")
      end

    end
  end

  describe "Associations" do
    it{ should belong_to :project }
    it{ should have_many :contributions }
  end

  it "should have a minimum value" do
    r = build(:reward, minimum_value: nil)
    r.should_not be_valid
  end

  it "should have a greater than 10.00 minimum value" do
    r = build(:reward)
    r.minimum_value = -0.01
    r.should_not be_valid
    r.minimum_value = 9.99
    r.should_not be_valid
    r.minimum_value = 10.00
    r.should be_valid
    r.minimum_value = 10.01
    r.should be_valid
  end

  it "should have a description" do
    r = build(:reward, description: nil)
    r.should_not be_valid
  end

  it "should have integer maximum contributions" do
    r = build(:reward)
    r.maximum_contributions = 10.01
    r.should_not be_valid
    r.maximum_contributions = 10
    r.should be_valid
  end

  it "should have maximum contributions > 0" do
    r = build(:reward)
    r.maximum_contributions = -1
    r.should_not be_valid
    r.maximum_contributions = 0
    r.should_not be_valid
    r.maximum_contributions = 1
    r.should be_valid
  end

  describe '.remaining' do
    subject { Reward.remaining }
    before do
      @remaining = create(:reward, maximum_contributions: 3)
      create(:contribution, state: 'confirmed', reward: @remaining, project: @remaining.project)
      create(:contribution, state: 'waiting_confirmation', reward: @remaining, project: @remaining.project)
      @sold_out = create(:reward, maximum_contributions: 2)
      create(:contribution, state: 'confirmed', reward: @sold_out, project: @sold_out.project)
      create(:contribution, state: 'waiting_confirmation', reward: @sold_out, project: @sold_out.project)
    end

    it{ should == [@remaining] }
  end

  describe '#sold_out?' do
    let(:reward) { create(:reward, maximum_contributions: 3) }
    subject { reward.sold_out? }

    context 'when reward not have limits' do
      let(:reward) { create(:reward, maximum_contributions: nil) }
      it { should be_false }
    end

    context 'when reward contributions waiting confirmation and confirmed are greater than limit' do
      before do
        2.times { create(:contribution, state: 'confirmed', reward: reward, project: reward.project) }
        create(:contribution, state: 'waiting_confirmation', reward: reward, project: reward.project)
      end

      it { should be_true }
    end

    context 'when reward contributions waiting confirmation and confirmed are lower than limit' do
      before do
        create(:contribution, state: 'confirmed', reward: reward, project: reward.project)
        create(:contribution, state: 'waiting_confirmation', reward: reward, project: reward.project)
      end
      it { should be_false }

    end
  end
end
