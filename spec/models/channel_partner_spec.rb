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

  describe '#convert_url' do
    context "with invalid url" do
      let(:partner) { create(:channel_partner, url: 'www.google.com.br') }
      before do
        partner.convert_url
      end

      it { expect(partner.url).to eq('http://www.google.com.br') }
    end

    context "with https url" do
      let(:partner) { create(:channel_partner, url: 'https://www.google.com.br') }
      before do
        partner.convert_url
      end

      it { expect(partner.url).to eq('https://www.google.com.br') }
    end
  end
end
