require 'spec_helper'

describe OauthProvider, :type => :model do
  describe "Associations" do
    it{ is_expected.to have_many :authorizations }
  end
end
