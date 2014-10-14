require 'rails_helper'

RSpec.describe State, type: :model do
  subject { create(:state) }

  describe "validations" do
    %w[name acronym].each do |field|
      it{ is_expected.to validate_presence_of field }
      it{ is_expected.to validate_uniqueness_of field }
    end
  end
end
