# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Explore projects Feature" do

  before(:each) do

    #Categories
    category_1 = Factory(:category)
    category_2 = Factory(:category)
    
    # Recommended projects (some of them expired)
    10.times do
      Factory(:project, created_at: 30.days.ago, expires_at: 30.days.from_now, visible: true, recommended: true, category: category_1)
    end
    5.times do
      Factory(:project, created_at: 30.days.ago, expires_at: 10.days.ago, visible: true, recommended: true, category: category_1)
    end

    # Expiring projects
    for days in 1..10 do
      Factory(:project, created_at: 30.days.ago, expires_at: days.days.from_now, visible: true, recommended: false, category: category_1)
    end

    # Recent projects
    for days in 1..10 do
      Factory(:project, created_at: days.days.ago, expires_at: 30.days.from_now, visible: true, recommended: false, category: category_2)
    end
    
    # Successful projects
    for days in 1..10 do
      project = Factory(:project, created_at: 30.days.ago, expires_at: days.days.ago, visible: true, recommended: false, category: category_2)
      Factory(:backer, project: project, value: project.goal, confirmed: true)
    end
    
  end
  
  scenario "When I visit explore projects, it should show the correct projects" do

    categories = Category.with_projects.order(:name).all
    recommended = Project.visible.not_expired.recommended.order('expires_at').all
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
    
    visit "/pt/explore/recommended"
    verify_translations

    projects = Project.visible.not_expired.recommended.order('expires_at').all
    within "#explore_results" do
      list = all(".project_box")
      list.each_index do |index|
        next unless list[index].visible?
        list[index].find("a")[:href].should match(/\/projects\/#{projects[index].to_param}/)
      end
    end
    find('#explore_menu .selected').text.should == "Recomendados".upcase

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
