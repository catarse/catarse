# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'Constants' do
    it 'has REQUIRED_ATTRIBUTES constant' do
      expect(described_class::REQUIRED_ATTRIBUTES).to eq %i[
        address_city address_zip_code phone_number address_neighbourhood address_street address_number
      ].freeze
    end
  end

  describe 'Instance methods' do
    describe '#required_attributes' do
      context 'when is international' do
        before { allow(subject).to receive(:international?).and_return(true) }

        it 'doesn`t includes address_number address_neighbourhood and phone_number' do
          expect(subject.required_attributes).to_not include(:address_number, :address_neighbourhood, :phone_number)
        end
      end

      context 'when isn`t international' do
        before { allow(subject).to receive(:international?).and_return(false) }

        it 'returns REQUIRED_ATTRIBUTES constant' do
          expect(subject.required_attributes).to eq described_class::REQUIRED_ATTRIBUTES
        end
      end
    end

    describe '#international?' do
      context 'when country is Brasil' do
        before { allow(subject).to receive_message_chain('country.name').and_return('Brasil') }

        it { is_expected.to_not be_international }
      end

      context 'when country isn`t Brasil' do
        before { allow(subject).to receive_message_chain('country.name').and_return('United States') }

        it { is_expected.to be_international }
      end
    end
  end
end
