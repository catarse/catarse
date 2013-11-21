require 'spec_helper'

describe Project::CustomValidators do
  describe '#permalink_on_routes?' do
    it 'should allow a unique permalink' do
      Project.permalink_on_routes?('permalink_test').should be_false
    end

    it 'should not allow a permalink to be one of catarse\'s routes' do
      Project.permalink_on_routes?('projects').should be_true
    end
  end
end
