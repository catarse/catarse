require 'spec_helper'

describe Channel do
  describe "Validations & Assoaciations" do

    [:name, :description, :permalink].each do |attribute|
      it { should validate_presence_of      attribute }
      it { should allow_mass_assignment_of  attribute }
    end

    it "validates uniqueness of permalink" do
      # Creating a channel profile before, to check its uniqueness
      # Because permalink is also being validated on Database with not
      # NULL constraint
      create(:channel)
      should validate_uniqueness_of :permalink
    end


    it { should have_many :subscriber_reports }
    it { should have_many :channels_subscribers }
    it { should have_and_belong_to_many :projects }
    it { should have_and_belong_to_many :trustees }
    it { should have_and_belong_to_many :subscribers }
  end


  describe "#to_param" do
    let(:channel) { create(:channel) }
    it "should return the permalink" do
      expect(channel.to_param).to eq(channel.permalink)
    end
  end


  describe "#projects" do
    let(:channel) { create(:channel) }
    let(:project1) { create(:project, online_date: (Time.now - 21.days)) } 
    let(:project2) { create(:project, online_date: (Time.now - 20.days)) }
    before { channel.projects << project1 }
    before { channel.projects << project2 }

    it "should projects in more days online ascending order" do
      expect(channel.projects).to eq([project2, project1])
    end
  end
end
