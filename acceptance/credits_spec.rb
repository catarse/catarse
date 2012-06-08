# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Credits Feature" do

  before do
    fake_login
    user.update_attribute :credits, 60
    @backers = [
      Factory(:backer, user: user, confirmed: true, can_refund: true, requested_refund: false, refunded: false, value: 10, created_at: 8.days.ago),
    ]
    user.reload

    click_link I18n.t('layouts.header.account')
    verify_translations
    click_link 'Meus créditos'
    verify_translations
    current_path.should == user_path(user)

    within 'head title' do
      page.should have_content("#{user.display_name} · #{I18n.t('site.name')}") 
    end
  end

  scenario "I have backs to refund but not enough credits" do
    user.update_attribute :credits, 5
    rows = all("#user_credits table tbody tr")
    # And now I try to request refund for the fourth row, but don't have enough credits
    within rows[0] do
      rows[0].find(".status").find('a').click
      verify_translations
      column = rows[0].all("td")[4]
      # Needed this sleep because have_content is not returning the right value and thus capybara does not know it has to way for the AJAX to finish
      sleep 1
      column.text.should == "Você não possui créditos suficientes para realizar este estorno."
    end
    click_on "OK"
    verify_translations
    user.reload.credits.should == 5
    find("#current_credits").should have_content(user.display_credits)
  end

  scenario "I have credits and backs to refund" do
    find("#current_credits").should have_content(user.display_credits)

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
      columns[4].text.should == "Solicitar estorno"
    end

    # Disabling javascript confirm, because we cannot test it with Capybara
    page.evaluate_script('window.confirm = function() { return true; }')

    # Requesting refund for the third row
    within rows[0] do
      rows[0].find(".status").find('a').click
      verify_translations
      column = rows[0].all("td")[4]
      # Needed this sleep because have_content is not returning the right value and thus capybara does not know it has to way for the AJAX to finish
      sleep 1
      column.text.should == "Pedido enviado com sucesso"
    end
    click_on "OK"
    verify_translations
    user.reload
    user.credits.should == 50
    find("#current_credits").should have_content(user.display_credits)
  end
end
