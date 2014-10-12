require 'rails_helper'

RSpec.describe ChannelsSubscriber, type: :model do
  describe "associations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :channel }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of :user_id }
    it{ is_expected.to validate_presence_of :channel_id }
  end
end
