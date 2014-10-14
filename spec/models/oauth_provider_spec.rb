require 'rails_helper'

RSpec.describe OauthProvider, type: :model do
  describe "Associations" do
    it{ is_expected.to have_many :authorizations }
  end
end
