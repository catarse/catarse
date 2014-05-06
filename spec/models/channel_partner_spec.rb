require 'spec_helper'

describe ChannelPartner do
  describe "associations" do
    it{ should belong_to :channel }
  end

  describe "validations" do
    %w[channel_id url image].each do |field|
      it{ should validate_presence_of field }
    end
  end
end
