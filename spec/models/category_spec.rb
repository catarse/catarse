require 'spec_helper'

describe Category do
  let(:category) { create(:category) }
  let(:category_2) { create(:category) }

  describe "Associations" do
    before do
      category
    end

    it{ should have_many :projects }
    it{ should validate_presence_of :name_pt }
    it{ should validate_uniqueness_of :name_pt }
  end

  describe "#with_projects" do
    before do
      create(:project, category: category, state: 'online')
      create(:project, category: category, state: 'successful')
      create(:project, category: category_2, state: 'draft')
      create(:project, category: category_2, state: 'rejected')
    end

    subject { Category.with_projects }

    it "should return only categories that have a least one project (online, successful, failed or waiting_funds)" do
      expect(subject.count).to eq(1)
    end
  end

  describe ".total_online_projects" do
    before do
      2.times { create(:project, category: category, state: 'online') }
      create(:project, category: category, state: 'successful')
    end

    subject { category.total_online_projects }
    it { expect(subject).to eq(2) }
  end
end
