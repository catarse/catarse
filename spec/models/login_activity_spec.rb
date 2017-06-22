# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginActivity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
