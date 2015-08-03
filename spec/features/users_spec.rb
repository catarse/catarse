# coding: utf-8

require 'rails_helper'

RSpec.describe "Users", type: :feature do
  before do
    I18n.locale = :pt
    OauthProvider.create! name: 'facebook', key: 'dummy_key', secret: 'dummy_secret'
  end

  describe "redirect to the last page after login" do
    before do
      @project = create(:project)
      visit project_by_slug_path(permalink: @project.permalink)
      login
    end

    it { expect(current_path).to eq(project_by_slug_path(permalink: @project.permalink)) }
  end

  describe "Unsubscribing from all project notifications" do
    let(:set_initial_unsubscribe_state){ nil }

    def toggle_subscription state
      # Had to use JS here, capybara was triggering some bizarre errors
      expect(page.evaluate_script('$("#user_subscribed_to_project_posts").is(":checked")')).to eq !state
      page.execute_script "$('#user_subscribed_to_project_posts').prop('checked', #{state})"
      page.execute_script "$('#save').click()"
      sleep FeatureHelpers::TIME_TO_SLEEP
      expect(page.evaluate_script('$("#user_subscribed_to_project_posts").is(":checked")')).to eq state
    end

    before do
      login
      set_initial_unsubscribe_state
      visit edit_user_path current_user, anchor: 'notifications'
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    context "when user is unsubscribed" do
      let(:set_initial_unsubscribe_state){ current_user.update_attributes subscribed_to_project_posts: false }
      it "should check the checkbox and add a record to unsubscribes with project_id null" do
        toggle_subscription true
      end
    end

    context "when user is subscribed" do
      it "should uncheck the checkbox and add a record to unsubscribes with project_id null" do
        toggle_subscription false
      end
    end
  end

  describe "View public profile page" do
    before do
      @user = create(:user) 
      5.times{ create(:project, user: @user) } 
      5.times{ create(:confirmed_contribution, user: @user) }
    end

    it "should describe the date the user signed up, the total number of projects created and the total number of contributions on the profile page" do
      visit(user_path(@user))      
      sleep FeatureHelpers::TIME_TO_SLEEP
      expect(page).to have_content I18n.t('users.profile.user_since', date: I18n.localize(@user.created_at, format: "%B de %Y"))
      expect(page).to have_content I18n.t('users.profile.multiple_project_created', n_projects: 5)
      expect(page).to have_content I18n.t('users.profile.multiple_project_contribution', n_projects: 5)
    end
  end

end
