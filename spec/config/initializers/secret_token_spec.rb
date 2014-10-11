require 'rails_helper'
require 'securerandom'

RSpec.describe 'find_secure_token' do
  subject{ find_secure_token }

  it "should have been configured in initializer" do
    expect(Catarse::Application.config.secret_token).to_not be_nil
  end

  context 'when database does not contain secret_token in configurations' do
    before do
      ::CatarseSettings[:secret_token] = nil
    end
    it{ is_expected.not_to be_nil }
    it{ is_expected.to eq(::CatarseSettings[:secret_token]) }
  end

end

RSpec.describe 'find_secure_key_base' do
  subject{ find_secure_key_base }

  it "should have been configured in initializer" do
    expect(Catarse::Application.config.secret_key_base).to_not be_nil
  end

  context 'when database does not contain secret_key_base in configurations' do
    before do
      ::CatarseSettings[:secret_key_base] = nil
    end
    it{ is_expected.not_to be_nil }
    it{ is_expected.to eq(::CatarseSettings[:secret_key_base]) }
  end

end
