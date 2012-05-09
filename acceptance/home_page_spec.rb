# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Home Page Feature" do

  scenario "When I visit home page, it should show a compilation of projects and curated pages" do

    home_page = [
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true, recommended: true)
    ]

    expiring = [
      Factory(:project, created_at: 30.days.ago, expires_at: 2.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 3.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 4.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 5.days.from_now, visible: true, home_page: false)
    ]

    recent = [
      Factory(:project, created_at: 2.days.ago, expires_at: 30.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 3.days.ago, expires_at: 30.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 4.days.ago, expires_at: 30.days.from_now, visible: true, home_page: false),
      Factory(:project, created_at: 5.days.ago, expires_at: 30.days.from_now, visible: true, home_page: false)
    ]

    successful = [
      Factory(:project, created_at: 30.days.ago, expires_at: 2.days.ago, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 3.days.ago, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 4.days.ago, visible: true, home_page: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 5.days.ago, visible: true, home_page: false)
    ]
    successful.each do |project|
      Factory(:backer, project: project, value: project.goal, confirmed: true)
      project.successful?.should be_true
    end

    curated_pages = [
      Factory(:curated_page, created_at: 2.days.ago, visible: true),
      Factory(:curated_page, created_at: 3.days.ago, visible: true),
      Factory(:curated_page, created_at: 4.days.ago, visible: true),
      Factory(:curated_page, created_at: 5.days.ago, visible: true),
      Factory(:curated_page, created_at: 6.days.ago, visible: true),
      Factory(:curated_page, created_at: 7.days.ago, visible: true),
      Factory(:curated_page, created_at: 8.days.ago, visible: true),
      Factory(:curated_page, created_at: 2.days.ago, visible: false)
    ]

    visit homepage
    verify_translations

    within 'head title' do
      page.should have_content("#{I18n.t('site.title')} · #{I18n.t('site.name')}") 
    end

    titles = all(".list_title .title h2")
    titles.shift.text.should == "seleção"
    titles.shift.text.should == "na reta final"
    titles.shift.text.should == "novos e fresquinhos"
    titles.shift.text.should == "parceiros"

    home_page_list = all(".selected_projects .curated_project")
    home_page_list.should have(3).items

    lists = all(".list")

    expiring_list = lists.shift.all(".curated_project")
    expiring_list.should have(3).items

    recent_list = lists.shift.all(".curated_project")
    recent_list.should have(3).items

    successful_list = lists.shift.all(".curated_project")
    successful_list.should have(3).items

    curated_pages_list = find(".partners").all("li")
    curated_pages_list.should have(6).items

    curated_pages_list.each_index do |index|
      within curated_pages_list[index] do
        find("a")[:href].should match(/\/#{curated_pages[index].permalink}/)
      end
    end
  end

end
