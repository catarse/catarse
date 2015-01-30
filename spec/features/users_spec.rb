# coding: utf-8

require 'rails_helper'

RSpec.describe "Users", type: :feature do
  before do
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

end

