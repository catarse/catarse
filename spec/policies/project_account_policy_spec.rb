require 'rails_helper'

RSpec.describe ProjectAccountPolicy do
  subject { ProjectAccountPolicy }

  shared_examples_for "create permissions" do
    it "should deny access if project is online" do
      is_expected.not_to permit(build(:user, admin: true), ProjectAccount.new(project: create(:project, state: 'online')))
    end

    it "should allow access if project is not online" do
      is_expected.to permit(build(:user, admin: true), ProjectAccount.new(project: create(:project, state: 'draft')))
    end
    it "should deny access if user is not admin or owner" do
      is_expected.to_not permit(build(:user, admin: false), ProjectAccount.new(project: create(:project, state: 'draft')))
    end
  end

  permissions :update? do
    it_should_behave_like "create permissions"
  end

end
