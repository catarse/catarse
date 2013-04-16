# coding: utf-8

require 'spec_helper'

describe "Users" do
  before do
    FactoryGirl.create(:notification_type, name: 'updates')
    OauthProvider.create! name: 'facebook', key: 'dummy_key', secret: 'dummy_secret'    
  end

  describe "the notification tab" do
    before do
      login
      @project = FactoryGirl.create(:backer, user: current_user).project
      visit user_path(current_user, locale: :pt)
      click_link 'unsubscribes_link'
    end

    it "should show unsubscribe from all updates" do
      updates_unsubscribe = all("#user_unsubscribes_attributes_0_subscribed")
      updates_unsubscribe.should have(1).items
    end

    it "should show unsubscribe from backed projects" do
      project_unsubscribe = all("#user_unsubscribes_attributes_1_subscribed")
      project_unsubscribe.should have(1).items
      find("label[for=user_unsubscribes_attributes_1_subscribed]").text.should == @project.name
      find("#user_unsubscribes_attributes_1_project_id").value.should == @project.id.to_s
    end

  end
end

