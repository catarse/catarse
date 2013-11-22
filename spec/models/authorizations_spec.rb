require 'spec_helper'

describe Authorization do
  describe "Associations" do
    it{ should belong_to :user }
    it{ should belong_to :oauth_provider }
  end

  describe "Validations" do
    it{ should validate_presence_of :oauth_provider } 
    it{ should validate_presence_of :user } 
    it{ should validate_presence_of :uid } 
  end
end
