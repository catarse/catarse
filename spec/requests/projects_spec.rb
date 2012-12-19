# coding: utf-8

require 'spec_helper'

describe "Projects" do
  describe "projects_path" do
    before do
      Factory(:project, state: 'online', expires_at: Time.now + 1.month)
      visit root_path(:locale => :pt)
    end

    it "should show recent projects" do
      recent = all(".recents_projects.list .projects .curated_project")
      recent.should have(1).items
    end
  end
end
