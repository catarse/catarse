require 'rails_helper'

RSpec.describe Category, :type => :model do
  describe "Associations" do
    before do
      FactoryGirl.create :category
    end

    it{ is_expected.to have_many :projects }
    it{ is_expected.to validate_presence_of :name_pt }
    it{ is_expected.to validate_uniqueness_of :name_pt }
  end
end
