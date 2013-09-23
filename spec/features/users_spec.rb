# coding: utf-8

require 'spec_helper'

describe "Users" do
  before do
    create(:notification_type, name: 'updates')
    OauthProvider.create! name: 'facebook', key: 'dummy_key', secret: 'dummy_secret'
  end

  describe "redirect to the last page after login" do
    before do
      @project = create(:project)
      visit project_by_slug_path(permalink: @project.permalink)
      login
    end

    it { current_path.should == project_by_slug_path(permalink: @project.permalink) }
  end

  describe "the notification tab" do
    before do
      login
      @project = create(:backer, user: current_user).project
      visit user_path(current_user, locale: :pt)
      click_link 'unsubscribes_link'
      sleep 1
    end

    it "should show unsubscribe from all updates" do
      updates_unsubscribe = all("#user_unsubscribes_attributes_0_subscribed")
      updates_unsubscribe.should have(1).items
    end

    it "should show unsubscribe from backed projects" do
      project_unsubscribe = all("input#user_unsubscribes_1")
      project_unsubscribe.should have(1).items
      find("label[for=user_unsubscribes_1]").text.should == @project.name
      find("input#user_unsubscribes_1").value.should == @project.id.to_s
    end

  end
end

