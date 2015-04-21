# coding: utf-8

require 'rails_helper'

RSpec.describe "Contributions", type: :feature do
  let(:project){ create(:project, state: 'online') }

  before do
    login 
    5.times{ create(:reward, project: project) }
    visit project_path(project)  
  end

  #NOTE: It looks like Capybara has issues with input masks: https://github.com/thoughtbot/capybara-webkit/issues/303
  def send_keys_inputmask(location, keys)
    len = keys.length - 1
    (0..keys.length - 1).each_with_index do |e,i|
      find(location).click
      find(location).native.send_keys keys[i]
    end
  end

  def pay
    fill_in 'payment_card_name', with: 'FULANO DE TAL'
    #fill_in 'payment_card_number', with: '4012888888881881'
    send_keys_inputmask('#payment_card_number','4012888888881881')
    fill_in 'payment_card_source', with: '606'
    #fill_in 'payment_card_date', with: '06/2020'
    send_keys_inputmask('#payment_card_date','06/2020')
    find("#credit_card_submit").click
    sleep FeatureHelpers::TIME_TO_SLEEP*2
  end

  describe "contribution navigation" do
    context "when project status is failed" do
      let(:project){ create(:project, state: 'failed') }
      it "should not redirect after clicking on reward card" do
        uri_before = URI.parse(current_url)
        first(".card-reward").click
        uri_after = URI.parse(current_url)
        expect(uri_before).to eq(uri_after+"#project-offline")
      end
    end
    
    context "when project status is successful" do
      let(:project){ create(:project, state: 'successful') }
      it "should not redirect after clicking on reward card" do
        uri_before = URI.parse(current_url)
        first(".card-reward").click
        uri_after = URI.parse(current_url)
        expect(uri_before).to eq(uri_after+"#project-offline")
      end
    end
    
    it "should redirect to contribution/new page after clicking on the contribute button" do
      find("#contribute_project_form").click
      uri = URI.parse(current_url)
      expect(uri).to have_content('contributions/new')
    end
    
    it "should redirect to contribution/edit page after selecting reward and clicking forward" do
      find("#contribute_project_form").click
      find(".back-reward-radio-reward:nth-of-type(2)").first("label").click
      reward_id = find("input[name='contribution[reward_id]']:checked").value
      find("#submit").click
      uri = URI.parse(current_url)
      expect(uri).to have_content("contributions/#{reward_id}/edit")
    end
    
    it "should redirect with selected reward when clicking on card reward" do
      selected_card = find(".card-reward:nth-of-type(2)")
      uri_after = selected_card["data-new-contribution-url"]
      reward_id = selected_card["id"].split("_").last
      selected_card.click
      uri = URI.parse(current_url)
      expect(page.has_checked_field?(reward_id)).to be true
      expect(uri).to have_content(uri_after)
    end
  end

  describe "contribution payment" do
    it "should redirect to thank you page after paying with a credit card" do
      find("#contribute_project_form").click
      find(".back-reward-radio-reward:nth-of-type(2)").first("label").click
      find("#submit").click
      find("#next-step").click
      pay
      expect(page).to have_content(I18n.t('projects.contributions.show.thank_you'))
    end
    
    it "should redirect to thank you page after paying a contribution without reward with a credit card" do
      find("#contribute_project_form").click
      find("#submit").click
      find("#next-step").click
      pay
      expect(page).to have_content(I18n.t('projects.contributions.show.thank_you'))
    end
    
    it "should redirect to thank you page after paying with a credit card a no reward contribution" do
      find("#contribute_project_form").click
      find("#submit").click
      find("#next-step").click
      pay
      expect(page).to have_content(I18n.t('projects.contributions.show.thank_you'))
    end
  end
end