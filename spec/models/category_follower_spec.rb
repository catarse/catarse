require 'rails_helper'

RSpec.describe CategoryFollower, :type => :model do
  describe "Associations" do
    before do
      create(:category_follower)
    end

    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :category }
  end
end
