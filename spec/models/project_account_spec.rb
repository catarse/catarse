# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe ProjectAccount, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :bank }
    it { is_expected.to have_many :project_account_errors }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:address_street) }
    it { is_expected.to validate_presence_of(:address_state) }
    it { is_expected.to validate_presence_of(:address_city) }
    it { is_expected.to validate_presence_of(:address_zip_code) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:bank) }
    it { is_expected.to validate_presence_of(:agency) }
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_presence_of(:account_digit) }
    it { is_expected.to validate_presence_of(:owner_name) }
    it { is_expected.to validate_presence_of(:owner_document) }

    it{ is_expected.to allow_value('12345').for(:account) }
    it{ is_expected.not_to allow_value('1A2345').for(:account) }
  end
end
