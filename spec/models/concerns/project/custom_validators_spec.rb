require 'spec_helper'

describe Project::CustomValidators, :type => :model do
  describe '#permalink_on_routes?' do
    it 'should allow a unique permalink' do
      expect(Project.permalink_on_routes?('permalink_test')).to eq(false)
    end

    it 'should not allow a permalink to be one of catarse\'s routes' do
      expect(Project.permalink_on_routes?('projects')).to eq(true)
    end
  end
end
