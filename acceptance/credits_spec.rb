# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Credits Feature" do

  before do
    fake_login
    Factory(:notification_type, name: 'updates')
    project = Factory(:project, finished: true, successful: false)
    @backers = [
      Factory(:backer, user: user, project: project, confirmed: true, requested_refund: false, refunded: false, value: 20, created_at: 8.days.ago)
    ]
    user.reload

    sleep 4

    click_link I18n.t('layouts.header.account')
    click_link I18n.t('credits.index.title')
    current_path.should == user_path(user)

    within 'head title' do
      page.should have_content("#{user.display_name} · #{I18n.t('site.name')}")
    end
  end

  scenario "I have backs to refund but not enough credits" do
    Factory(:backer, credits: true, value: 10, user: user)
    user.reload
    rows = all("#user_credits table tbody tr")
    # And now I try to request refund for the fourth row, but don't have enough credits
    within rows[0] do
      rows[0].find(".status").find('a').click
      verify_translations
      column = rows[0].all("td")[4]
      # Needed this sleep because have_content is not returning the right value and thus capybara does not know it has to way for the AJAX to finish
      sleep 3
      column.text.should == I18n.t('credits.refund.no_credits')
    end
    click_on "OK"
    find("#current_credits").should have_content(user.display_credits)
  end

  scenario "I have credits and backs to refund" do
    rows = all("#user_credits table tbody tr")
    rows.should have(1).items

    # Testing the content of the whole table
    rows.each do |row|
      columns = row.all("td")
      id = row[:id].split("_").last
      backer = @backers.first

      columns[0].find("a")[:href].should match(/\/projects\/#{backer.project.to_param}/)
      columns[1].text.should == I18n.l(backer.created_at.to_date)
      columns[2].text.should == backer.display_value
      columns[3].text.should == I18n.l(backer.refund_deadline.to_date)
      columns[4].text.should == I18n.t('credits.index.request_refund')
    end

    # Disabling javascript confirm, because we cannot test it with Capybara
    page.evaluate_script('window.confirm = function() { return true; }')

    # Requesting refund for the third row
    within rows[0] do
      rows[0].find(".status").find('a.link_project').click
      sleep 2
      verify_translations
      page.evaluate_script('window.confirm = function() { return true; }')
      column = rows[0].all("td")[4]
      # Needed this sleep because have_content is not returning the right value and thus capybara does not know it has to wait for the AJAX to finish
      sleep 2
      column.text.should == I18n.t('credits.index.refunded')
    end
    click_on "OK"
  end
end
