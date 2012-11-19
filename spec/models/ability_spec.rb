require 'spec_helper'
require "cancan/matchers"

describe Ability do
  let(:user){ Factory(:user) }
  let(:project){ Factory(:project) }
  subject{ Ability.new(user) }

  context "when user is admin" do
    let(:user){ Factory(:user, :admin => true) }
    it{ should be_able_to(:manage, Category) }
    it{ should be_able_to(:manage, Configuration) }
    it{ should be_able_to(:manage, Category) }
    it{ should be_able_to(:manage, Project) }
    it{ should be_able_to(:manage, User) }
    it{ should be_able_to(:manage, Update) }
  end

  context "when user is not an admin nor project manager" do
    it{ should_not be_able_to(:manage, Category) }
    it{ should_not be_able_to(:manage, Configuration) }
    it{ should_not be_able_to(:manage, Category) }
    it{ should_not be_able_to(:manage, Update) }
    it{ should_not be_able_to(:manage, project) }
    it{ should_not be_able_to(:manage, Factory(:user)) }
  end

  context "when user is manager of the project" do
    let(:project){ Factory(:project, :managers => [user]) }
    let(:reward){ Factory(:reward, :project => project) }
    let(:update){ Factory(:update, :project => project) }
    it{ should be_able_to(:manage, project) }
    it{ should be_able_to(:manage, reward) }
    it{ should be_able_to(:manage, update) }
  end

end
