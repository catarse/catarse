# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Explore projects Feature" do

  before(:each) do
    # Recommended projects
    Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, recommended: true)
    Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, recommended: true)
    Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, recommended: true)

    # Expiring projects
    Factory(:project, created_at: 30.days.ago, expires_at: 2.days.from_now, visible: true, recommended: false)
    Factory(:project, created_at: 30.days.ago, expires_at: 3.days.from_now, visible: true, recommended: false)
    Factory(:project, created_at: 30.days.ago, expires_at: 4.days.from_now, visible: true, recommended: false)

    # Recent projects
    Factory(:project, created_at: 2.days.ago, expires_at: 30.days.from_now, visible: true, recommended: false)
    Factory(:project, created_at: 3.days.ago, expires_at: 30.days.from_now, visible: true, recommended: false)
    Factory(:project, created_at: 4.days.ago, expires_at: 30.days.from_now, visible: true, recommended: false)
    
    # Successful projects
    successful = [
      Factory(:project, created_at: 30.days.ago, expires_at: 2.days.ago, visible: true, recommended: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 3.days.ago, visible: true, recommended: false),
      Factory(:project, created_at: 30.days.ago, expires_at: 4.days.ago, visible: true, recommended: false)
    ]
    successful.each do |project|
      Factory(:backer, project: project, value: project.goal, confirmed: true)
    end
  end
  
  scenario "When I visit explore projects, it should show" do

    categories = Category.with_projects.order(:name).all
    recommended = Project.visible.recommended.order('created_at DESC').all
    expiring = Project.visible.expiring.limit(16).order('expires_at').all
    recent = Project.visible.recent.limit(16).order('created_at DESC').all
    successful = Project.visible.successful.order('expires_at DESC').all

    visit homepage
    verify_translations
    
    click_on "Explore os projetos"
    verify_translations
    
    within 'head title' do
      page.should have_content("Explore os projetos · #{I18n.t('site.name')}") 
    end

    quick_list = find("#explore_quick").all("li")
    quick_list[0].text.should == "Recomendados".upcase
    quick_list[1].text.should == "Na reta final".upcase
    quick_list[2].text.should == "Recentes".upcase
    quick_list[3].text.should == "Bem-sucedidos".upcase
    
    categories_list = find("#explore_categories").all("li")
    categories_list.each_index do |index|
      categories_list[index].text.should == categories[index].name.upcase
    end

    # It should be already on recommended projects
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{recommended[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recomendados".upcase
    
    # Now I go to expiring projects
    within "#explore_menu" do
      click_on "Na reta final"
    end
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{expiring[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Na reta final".upcase
    
    # Now I go to recent projects
    within "#explore_menu" do
      click_on "Recentes"
    end
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{recent[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recentes".upcase
    
    # Now I go to successful projects
    within "#explore_menu" do
      click_on "Bem-sucedidos"
    end
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{successful[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Bem-sucedidos".upcase
    
    # Now I go to recommended projects again
    within "#explore_menu" do
      click_on "Recomendados"
    end
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{recommended[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recomendados".upcase

    # Now I go through every category
    categories.each do |category|
      projects = Project.visible.where(category_id: category.id).order('created_at DESC').all
      within "#explore_menu" do
        click_on category.name
      end
      within "#explore_results" do
        list = all(".project_box")
        list.each_index do |index|
          next unless list[index].visible?
          list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
        end
      end
      find('#explore_menu .selected').text.should == category.name.upcase
    end
    
  end

  scenario "I visit /pt/explore/recommended directly" do
    
    visit "/pt/explore/recommended"
    verify_translations

    projects = Project.visible.recommended.order('created_at DESC').all
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recomendados".upcase
    
  end

  scenario "I visit /pt/explore/expiring directly" do
    
    visit "/pt/explore/expiring"
    verify_translations

    projects = Project.visible.expiring.limit(16).order('expires_at').all
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Na reta final".upcase
    
  end

  scenario "I visit /pt/explore/recent directly" do
    
    visit "/pt/explore/recent"
    verify_translations

    projects = Project.visible.recent.limit(16).order('created_at DESC').all
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recentes".upcase
    
  end

  scenario "I visit /pt/explore/successful directly" do
    
    visit "/pt/explore/successful"
    verify_translations

    projects = Project.visible.successful.order('expires_at DESC').all
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Bem-sucedidos".upcase
    
  end

end
