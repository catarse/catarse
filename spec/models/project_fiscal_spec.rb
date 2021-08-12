# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectFiscal, type: :model do
  describe 'Relations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:begin_date) }

    it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(1) }
    it { is_expected.to validate_numericality_of(:total_catarse_fee).is_greater_than_or_equal_to(1) }
    it { is_expected.to validate_numericality_of(:total_gateway_fee).is_greater_than_or_equal_to(1) }
  end
end
