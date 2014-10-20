require 'rails_helper'

RSpec.describe Channel, type: :model do
  describe "Validations & Assoaciations" do

    [:name, :description, :permalink].each do |attribute|
      it { is_expected.to validate_presence_of      attribute }
      it { is_expected.to allow_mass_assignment_of  attribute }
    end

    it "validates uniqueness of permalink" do
      # Creating a channel profile before, to check its uniqueness
      # Because permalink is also being validated on Database with not
      # NULL constraint
      create(:channel)
      is_expected.to validate_uniqueness_of :permalink
    end


    it { is_expected.to have_many :subscriber_reports }
    it { is_expected.to have_many :channels_subscribers }
    it { is_expected.to have_many :users }
    it { is_expected.to have_and_belong_to_many :projects }
    # Comment out due to possible bug in shoulda-matchers
    #it { is_expected.to have_and_belong_to_many :subscribers }
  end

  describe ".by_permalink" do
    before do
      @c1 = create(:channel, permalink: 'foo')
      @c2 = create(:channel, permalink: 'bar')
    end

    subject { Channel.by_permalink('foo') }

    it { is_expected.to eq([@c1]) }
  end

  describe '.find_by_permalink!' do
    before do
      @c1 = create(:channel, permalink: 'Foo')
      @c2 = create(:channel, permalink: 'bar')
    end

    subject { Channel.find_by_permalink!('foo') }

    it { is_expected.to eq(@c1) }
  end


  describe "#to_param" do
    let(:channel) { create(:channel) }
    it "should return the permalink" do
      expect(channel.to_param).to eq(channel.permalink)
    end
  end


  describe "#has_subscriber?" do
    let(:channel) { create(:channel) }
    let(:user) { create(:user) }
    subject{ channel.has_subscriber? user }

    context "when user is nil" do
      let(:user) { nil }
      it{ is_expected.to eq(nil) }
    end

    context "when user is a channel subscriber" do
      before do
        channel.subscribers = [user]
        channel.save!
      end
      it{ is_expected.to eq(true) }
    end

    context "when user is not a channel subscriber" do
      it{ is_expected.to eq(false) }
    end
  end

  describe "#curator" do
    subject{ channel.curator }

    let(:channel) { create(:channel) }
    let(:curator) { create(:user, channel: channel) }
    before do
      curator
      create(:user, channel: channel)
    end
    it{ is_expected.to eq(curator) }
  end

  describe "#projects" do
    let(:channel) { create(:channel) }
    let(:project1) { create(:project, online_date: (Time.now - 21.days)) }
    let(:project2) { create(:project, online_date: (Time.now - 20.days)) }
    let(:project3) { create(:project, state: "waiting_funds", online_date: (Time.now - 21.days)) }
    before { channel.projects << project1 }
    before { channel.projects << project2 }
    before { channel.projects << project3 }

    it "should projects in more days online ascending order and online projects first" do
      expect(channel.projects).to eq([project2, project1, project3])
    end
  end
end
