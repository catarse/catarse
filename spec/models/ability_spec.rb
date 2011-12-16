require 'spec_helper'
require "cancan/matchers"

describe Ability do
  it "should enable admin to manage everything" do
    user = Factory.build(:user, :admin => true)
    ability = Ability.new(user)
    ability.should be_able_to(:manage, Category)
    ability.should be_able_to(:manage, Configuration)
    ability.should be_able_to(:manage, Category)
    ability.should be_able_to(:manage, Project)
    ability.should be_able_to(:manage, User)
  end

  it "should not enable users to have admin privileges" do
    user = Factory.build(:user)
    user.save
    project = Factory.build(:project)
    project.save
    ability = Ability.new(user)
    ability.should_not be_able_to(:manage, Category)
    ability.should_not be_able_to(:manage, Configuration)
    ability.should_not be_able_to(:manage, Category)
    ability.should_not be_able_to(:manage, project)
    ability.should_not be_able_to(:manage, User)        
  end

  it "should enable users to manage only own projects" do
    user = Factory.build(:user)
    user.save
    project = Factory.build(:project, :managers => [user])
    project.save
    user2 = Factory.build(:user)
    user2.save
    ability = Ability.new(user)
    ability2 = Ability.new(user2)
    ability.should be_able_to(:manage, project)
    ability2.should_not be_able_to(:manage, project)
  end

  it "should enable user manage his own project rewards" do
    user = Factory.build(:user)
    user.save
    project = Factory.build(:project, :managers => [user])
    project.save
    reward = Factory.build(:reward, :project => project)
    reward.save
    ability = Ability.new(user)
    ability.should be_able_to(:manage, reward)
  end
end