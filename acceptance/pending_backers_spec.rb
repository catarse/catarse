# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Pending Backers" do

  before do
    fake_login
  end

  scenario "with non admin user" do
    visit pending_backers_projects_path
    verify_translations
    page.should have_css('.failure.wrapper')
  end

  scenario "with admin user, it should show a table with backers" do
    10.times { Factory(:backer) }

    user_to_admin(current_user)
    visit pending_backers_projects_path
    verify_translations

    page.should have_no_css('.failure.wrapper')
    within ".title" do
      page.should have_css('h1', :text => 'Gerenciamento de apoios')
    end

    page.should have_content "10 apoiadores"
    all(".bootstrap-twitter table tbody tr").should have(10).itens

  end

  scenario 'show backers in project page' do

    project = Factory(:project)
    a_user = Factory(:user)
    other_user = Factory(:user)
    backer = Factory(:backer, project: project, user: a_user, confirmed: false, anonymous: true, requested_refund: false)
    user_to_admin(current_user)

    visit project_path(project)
    verify_translations
    click_on "Apoiadores"
    verify_translations

    page.should have_css("#project_backers")
    page.should have_content "Ninguém apoiou este projeto ainda. Que tal ser o primeiro?"

    visit pending_backers_projects_path

    find("#confirmed__#{backer.id}")[:checked].should == nil
    find("#anonymous__#{backer.id}")[:checked].should == "true"
    find("#refunded__#{backer.id}")[:checked].should == nil

    within ".user_id" do
      page.should have_content("#{a_user.id}")
      find("span").click
      find("input").set("#{other_user.id}")
      click_on "OK"
      page.should have_content("#{other_user.id}")
    end

    check "confirmed__#{backer.id}"
    uncheck "anonymous__#{backer.id}"
    check "refunded__#{backer.id}"

    verify_translations

    find("#confirmed__#{backer.id}")[:checked].should == "true"
    find("#anonymous__#{backer.id}")[:checked].should == nil
    find("#refunded__#{backer.id}")[:checked].should == "true"

    backer.reload
    backer.user.should == other_user
    backer.confirmed.should == true
    backer.anonymous.should == false
    backer.refunded.should == true

    visit project_path(project)
    verify_translations
    click_on "Apoiadores"
    verify_translations

    within "#project_backers" do
      list = all("li")
      list.should have(1).items
      list[0].find("a")[:href].should match(/\/users\/#{other_user.to_param}/)
    end

  end

end
