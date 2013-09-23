require 'spec_helper'

describe State do
  subject { create(:state) }

  describe "validations" do
    %w[name acronym].each do |field|
      it{ should validate_presence_of field }
      it{ should validate_uniqueness_of field }
    end
  end
end
