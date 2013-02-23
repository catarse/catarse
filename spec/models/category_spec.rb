require 'spec_helper'

describe Category do
  describe "Associations" do
    before do
      FactoryGirl.create :category
    end

    it{ should have_many :projects }
    it{ should validate_presence_of :name_pt }
    it{ should validate_uniqueness_of :name_pt }
  end
end
