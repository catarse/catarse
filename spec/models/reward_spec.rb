# coding: utf-8

require 'rails_helper'

RSpec.describe Reward, type: :model do
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
    it{ is_expected.to belong_to :project }
    it{ is_expected.to have_many :contributions }
    it{ is_expected.to have_many(:payments).through(:contributions) }
  end

  it "should have a minimum value" do
    r = build(:reward, minimum_value: nil)
    expect(r).not_to be_valid
  end

  describe "check_if_is_destroyable" do
    before do
      create(:confirmed_contribution, project: reward.project, reward: reward)
      reward.reload
      reward.destroy
    end

    it { expect(reward.persisted?).to eq(true) }
  end

  it "should have a greater than 10.00 minimum value" do
    r = build(:reward)
    r.minimum_value = -0.01
    expect(r).not_to be_valid
    r.minimum_value = 9.99
    expect(r).not_to be_valid
    r.minimum_value = 10.00
    expect(r).to be_valid
    r.minimum_value = 10.01
    expect(r).to be_valid
  end

  it "should have a description" do
    r = build(:reward, description: nil)
    expect(r).not_to be_valid
  end

  it "should have integer maximum contributions" do
    r = build(:reward)
    r.maximum_contributions = 10.01
    expect(r).not_to be_valid
    r.maximum_contributions = 10
    expect(r).to be_valid
  end

  it "should not allow delivery in the past" do
    r = build(:reward, project: create(:project, online_date: nil))
    r.deliver_at = Time.current - 1.month
    expect(r).not_to be_valid
    r.deliver_at = Time.current + 1.month
    expect(r).to be_valid
  end

  it "should have maximum contributions > 0" do
    r = build(:reward)
    r.maximum_contributions = -1
    expect(r).not_to be_valid
    r.maximum_contributions = 0
    expect(r).not_to be_valid
    r.maximum_contributions = 1
    expect(r).to be_valid
  end

  describe '.remaining' do
    let(:project){ create(:project) }
    subject { Reward.remaining }
    before do
      project.rewards.first.destroy!
      @remaining = create(:reward, maximum_contributions: 3, project: project)
      create(:confirmed_contribution, reward: @remaining, project: @remaining.project)
      create(:pending_contribution, reward: @remaining, project: @remaining.project)
      payment = create(:pending_contribution, reward: @remaining, project: @remaining.project).payments.first
      payment.update_column(:created_at, 9.days.ago)

      @sold_out = create(:reward, maximum_contributions: 2, project: project)
      create(:confirmed_contribution, reward: @sold_out, project: @sold_out.project)
      create(:pending_contribution, reward: @sold_out, project: @sold_out.project)
    end

    it{ is_expected.to eq([@remaining]) }
  end

  describe "#valid?" do
    subject{ reward.valid? }

    context "when we have online_date in project and deliver_at is after expires_at" do
      let(:project){ create(:project, online_date: Time.now, online_days: 60) }
      let(:reward){ build(:reward, project: project, deliver_at: project.expires_at + 1.day) }
      it{ is_expected.to eq true }
    end

    context "when we have online_date in project and deliver_at is before expires_at month" do
      let(:reward){ build(:reward, project: project, deliver_at: project.expires_at - 1.month) }
      let(:project){ create(:project, online_date: Time.now, online_days: 60) }
      it{ is_expected.to eq false }
    end

    context "when online_date in project is nil and deliver_at is after current month" do
      let(:reward){ build(:reward, project: project, deliver_at: Time.now + 1.month) }
      let(:project){ create(:project, online_date: nil) }
      it{ is_expected.to eq true }
    end

    context "when online_date in project is nil and deliver_at is before current month" do
      let(:reward){ build(:reward, project: project, deliver_at: Time.now - 1.month) }
      let(:project){ create(:project, online_date: nil) }
      it{ is_expected.to eq false }
    end
  end

  describe "#total_contributions" do
    before do
      @remaining = create(:reward, maximum_contributions: 20)
      create(:confirmed_contribution, reward: @remaining, project: @remaining.project)
      create(:pending_contribution, reward: @remaining, project: @remaining.project)
      create(:refunded_contribution, reward: @remaining, project: @remaining.project)
    end

    context "get total of paid and peding contributions" do
      subject { @remaining.total_contributions %w(paid pending)}

      it { is_expected.to eq(2) }
    end

    context "get total of refunded contributions" do
      subject { @remaining.total_contributions %w(refunded)}

      it { is_expected.to eq(1) }
    end

    context "get tota of pending contributions" do
      subject { @remaining.total_contributions %w(pending)}

      it { is_expected.to eq(1) }
    end
  end

  describe "#total_compromised" do
    before do
      @remaining = create(:reward, maximum_contributions: 20)
      create(:confirmed_contribution, reward: @remaining, project: @remaining.project)
      create(:pending_contribution, reward: @remaining, project: @remaining.project)
    end

    subject { @remaining.total_compromised }

    it { is_expected.to eq(2) }
  end

  describe '#sold_out?' do
    let(:reward) { create(:reward, maximum_contributions: 3) }
    subject { reward.sold_out? }

    context 'when reward not have limits' do
      let(:reward) { create(:reward, maximum_contributions: nil) }
      it { is_expected.to eq(nil) }
    end

    context 'when reward contributions waiting confirmation and confirmed are greater than limit' do
      before do
        2.times { create(:confirmed_contribution, reward: reward, project: reward.project) }
        create(:pending_contribution, reward: reward, project: reward.project)
      end

      it { is_expected.to eq(true) }
    end

    context 'when reward contributions waiting confirmation and confirmed are lower than limit' do
      before do
        create(:confirmed_contribution, reward: reward, project: reward.project)
        create(:pending_contribution, reward: reward, project: reward.project)
      end
      it { is_expected.to eq(false) }

    end
  end
end
