require 'spec_helper'

describe OauthProvider do
  describe "Associations" do
    it{ should have_many :authorizations }
  end
end
