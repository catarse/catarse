require 'spec_helper'

describe Channel::Profile do
  describe "Validations" do

    [:name, :description, :permalink].each do |attribute|
      it { should validate_presence_of      attribute }
      it { should allow_mass_assignment_of  attribute }
    end

    it "validates uniqueness of permalink" do
      # Creating a channel profile before, to check its uniqueness
      # Because permalink is also being validated on Database with not
      # NULL constraint
      FactoryGirl.create(:channel_profile)
      should validate_uniqueness_of :permalink
    end
  end
end
