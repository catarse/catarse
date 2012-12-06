require 'spec_helper'
require "cancan/matchers"

describe Ability do
  subject { Ability.new(user) }

  context "When user is admin" do
    let(:user) { Factory(:user, admin: true) }

    it { should be_able_to(:access, :all) }
  end

  context "When user is project owner" do
    let(:user) { Factory(:user) }
    let(:project) { Factory(:project, user: user) }

    it { should_not be_able_to(:access, :all) }
    it { should be_able_to(:update, project) }
    it { should be_able_to(:create, :projects) }

    describe "our project is approved" do
      before { project.approve }
      it { should_not be_able_to(:update, project, :name) }
      it { should_not be_able_to(:update, project, :goal) }
      it { should_not be_able_to(:update, project, :video_url) }
      it { should be_able_to(:update, project, :about) }
    end
  end

  context "When is regular user" do
    let(:user) { Factory(:user) }
    let(:project) { Factory(:project) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, project) }
    it { should be_able_to(:create, :projects) }
  end

  context "When is a guest" do
    let(:user) { nil }
    let(:project) { Factory(:project) }

    it { should_not be_able_to(:access, :all) }
    it { should_not be_able_to(:update, project) }
    it { should_not be_able_to(:create, :projects) }
  end
end

#describe Ability do
  #let(:user){ Factory(:user) }
  #let(:project){ Factory(:project) }
  #subject{ Ability.new(user) }

  #context "when user is admin" do
    #let(:user){ Factory(:user, :admin => true) }
    #it{ should be_able_to(:access, Category) }
    #it{ should be_able_to(:access, Configuration) }
    #it{ should be_able_to(:access, Category) }
    #it{ should be_able_to(:access, Project) }
    #it{ should be_able_to(:access, User) }
    #it{ should be_able_to(:access, Update) }
  #end

  #context "when user is not an admin nor project manager" do
    #it{ should_not be_able_to(:access, Category) }
    #it{ should_not be_able_to(:access, Configuration) }
    #it{ should_not be_able_to(:access, Category) }
    #it{ should_not be_able_to(:access, Update) }
    #it{ should_not be_able_to(:access, project) }
    #it{ should_not be_able_to(:access, Factory(:user)) }
  #end

  #context "when user is manager of the project" do
    #let(:project){ Factory(:project, :managers => [user]) }
    #let(:reward){ Factory(:reward, :project => project) }
    #let(:update){ Factory(:update, :project => project) }
    #it{ should be_able_to(:access, project) }
    #it{ should be_able_to(:access, reward) }
    #it{ should be_able_to(:access, update) }
  #end

#end
