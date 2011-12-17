# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Home Page Feature" do

  scenario "I should be able to see and edit my profile when I click on 'Meu perfil'" do

    home_page = [
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true),
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, home_page: true)
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
   
    titles = all(".project_list_header")
    titles.shift.text.should == "Nossa seleção catártica!"
    titles.shift.text.should == "Na reta final"
    titles.shift.text.should == "Novos e fresquinhos"
    titles.shift.text.should == "Projetos bem-sucedidos"
    titles.shift.text.should == "Canais catárticos"

    home_page_list = find("#home_page_projects").all(".project_box")
    home_page_list.should have(6).items
    
    lists = all(".project_list")

    expiring_list = lists.shift.all(".project_box")
    expiring_list.should have(3).items
    
    recent_list = lists.shift.all(".project_box")
    recent_list.should have(3).items
    
    successful_list = lists.shift.all(".project_box")
    successful_list.should have(3).items
    
    curated_pages_list = find("#curated_pages_list").all("li")
    curated_pages_list.should have(6).items

    home_page_list.each_index do |index|
      within home_page_list[index] do
        find("a")[:href].should match(/\/projects\/#{home_page[index].to_param}/)
      end
    end
    
    expiring_list.each_index do |index|
      within expiring_list[index] do
        find("a")[:href].should match(/\/projects\/#{expiring[index].to_param}/)
      end
    end
    
    recent_list.each_index do |index|
      within recent_list[index] do
        find("a")[:href].should match(/\/projects\/#{recent[index].to_param}/)
      end
    end
    
    successful_list.each_index do |index|
      within successful_list[index] do
        find("a")[:href].should match(/\/projects\/#{successful[index].to_param}/)
      end
    end
    
    curated_pages_list.each_index do |index|
      within curated_pages_list[index] do
        find("a")[:href].should match(/\/#{curated_pages[index].permalink}/)
      end
    end
    
  end

end
