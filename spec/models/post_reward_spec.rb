# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostReward, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to :project_post }
    it { is_expected.to belong_to :reward }
  end
end
