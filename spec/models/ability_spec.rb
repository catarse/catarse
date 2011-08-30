require 'spec_helper'
require "cancan/matchers"

describe Category do
  it "should enable admin to manage everything" do
    user = Factory.build(:user, :admin => true)
    site = Factory.build(:site)
    category = Factory.build(:category)
    ability = Ability.new(user)
    ability.should be_able_to(:manage, Site)
    ability.should be_able_to(:manage, category)
    ability.should be_able_to(:manage, Configuration)
    ability.should be_able_to(:manage, Category)
    ability.should be_able_to(:manage, Project)
    ability.should be_able_to(:manage, User)
  end
end