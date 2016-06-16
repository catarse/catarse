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

  describe '#entity_type' do
    let(:document) { '111.111.111-11' }
    let(:project_account) { build(:project_account, owner_document: document) }

    subject { project_account.entity_type }

    context 'when owner_document is CNPJ' do
      let(:document) { '11.111.111/0001-11' }
      it { is_expected.to eq('Pessoa Jurídica') }
    end

    context 'when owner_document is CPF' do
      it { is_expected.to eq('Pessoa Física') }
    end

    context 'when owner_document is nil' do
      it { is_expected.to eq('Pessoa Física') }
    end
  end
end
