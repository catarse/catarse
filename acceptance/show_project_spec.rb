# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Show Project Feature" do

  include Rails.application.routes.url_helpers

  scenario "As an unlogged user, I want to see a project page" do

    project = Factory(:project)
    visit project_path(project)
    verify_translations

    page.should have_css(%@meta [property="og:title"][content="#{project.name}"]@)
    page.should have_css(%@meta [property="og:type"][content="cause"]@)
    page.should have_css(%@meta [property="og:url"][content="#{I18n.t('site.base_url')}#{project_path(project)}"]@)
    page.should have_css(%@meta [property="og:image"][content="#{project.display_image}"]@)
    page.should have_css(%@meta [property="og:site_name"][content="#{I18n.t('site.name')}"]@)
    page.should have_css(%@meta [property="og:description"][content="#{project.about}"]@)

    within '#project_header' do
      within 'h1' do
        page.should have_content(project.name)
      end
      within 'h2' do
        page.should have_content("Um projeto de #{project.user.name}")
      end
    end
    
    find("#project_about").visible?.should be_true
    within "#project_about" do
      page.should have_content(project.about)
    end
    find("#project_updates").visible?.should be_false
    find("#project_backers").visible?.should be_false
    find("#project_comments").visible?.should be_false

    # TODO: rewrite these specs once we have our new comments and updates systems
    # find("#updates_link .count").should have_content("(0)")
    click_link "Atualizações"
    verify_translations
    # find("#project_updates").visible?.should be_true
    # within "#empty_text" do
    #   page.should have_content("Este projeto ainda não teve atualizações. Aguarde =D")
    # end
    find("#project_about").visible?.should be_false
    find("#project_backers").visible?.should be_false
    find("#project_comments").visible?.should be_false

    find("#backers_link .count").should have_content("(0)")
    click_link "Apoiadores"
    verify_translations
    find("#project_backers").visible?.should be_true
    page.should have_content "Ninguém apoiou este projeto ainda. Que tal ser o primeiro?"
    find("#project_about").visible?.should be_false
    find("#project_updates").visible?.should be_false
    find("#project_comments").visible?.should be_false

    # TODO: rewrite these specs once we have our new comments and updates systems
    # find("#comments_link .count").should have_content("(0)")
    click_link "Comentários"
    verify_translations
    # find("#project_updates").visible?.should be_true
    # within "#project_comments" do
    #   page.should have_content "Quer enviar um comentário? Clique aqui para fazer login."
    # end
    find("#project_about").visible?.should be_false
    find("#project_updates").visible?.should be_false
    find("#project_backers").visible?.should be_false

    click_link("Sobre")
    verify_translations
    within "#project_about" do
      page.should have_content(project.about)
    end
    find("#project_updates").visible?.should be_false
    find("#project_backers").visible?.should be_false
    find("#project_comments").visible?.should be_false

  end

  scenario "As an unlogged user, I want to see a project page with updates, backers and comments" do
    
    project = Factory(:project)
    # TODO: rewrite these specs once we have our new comments and updates systems
    # 2.times { Factory(:comment, commentable: project, project_update: true) }
    3.times { Factory(:backer, project: project) }
    # TODO: rewrite these specs once we have our new comments and updates systems
    # 4.times { Factory(:comment, commentable: project) }

    visit project_path(project)
    
    # TODO: rewrite these specs once we have our new comments and updates systems
    # find("#updates_link .count").should have_content("(2)")
    # click_link "Atualizações"
    # verify_translations
    # within "#project_updates" do
    #   updates = project.updates.order("created_at DESC")
    #   list = all("li")
    #   list.should have(2).items
    #   list.each_index do |index|
    #     list[index].find("h3").text.should == updates[index].title
    #     list[index].find(".time").text.should == Unicode::upcase(updates[index].display_time)
    #     list[index].find(".comment").text.should == updates[index].comment
    #   end
    # end

    find("#backers_link .count").should have_content("(3)")
    click_link "Apoiadores"
    verify_translations
    within "#project_backers" do
      backers = project.backers.confirmed.order("confirmed_at DESC")
      list = all("li")
      list.should have(3).items
      list.each_index do |index|
        list[index].find("a")[:href].should match(/\/users\/#{backers[index].user.to_param}/)
      end
    end

    # TODO: rewrite these specs once we have our new comments and updates systems
    # find("#comments_link .count").should have_content("(4)")
    # click_link "Comentários"
    # verify_translations
    # within "#project_comments" do
    #   comments = project.comments.order("created_at DESC")
    #   list = all("li")
    #   list.should have(4).items
    #   list.each_index do |index|
    #     list[index].find("a")[:href].should match(/\/users\/#{comments[index].user.to_param}/)
    #     list[index].find(".time").text.should == Unicode::upcase(comments[index].display_time)
    #     list[index].find(".comment").text.should == comments[index].comment
    #   end
    # end

  end

  # TODO: rewrite these specs once we have our new comments and updates systems
  # scenario "As an unlogged user, before I comment I need to be asked to login" do
  # 
  #   project = Factory(:project)
  #   visit project_path(project)
  #   verify_translations
  #   
  #   click_link "Comentários"
  #   page.should have_css("#project_comments")
  # 
  #   within "#project_comments" do
  #     click_link "Clique aqui"
  #   end
  #   
  #   find("#login").visible?.should be_true
  # 
  # end

  # TODO: rewrite these specs once we have our new comments and updates systems
  # scenario "As a logged user, I want to comment a project" do
  # 
  #   fake_login
  #   
  #   project = Factory(:project)
  #   visit project_path(project)
  #   verify_translations
  #   
  #   click_link "Comentários"
  #   page.should have_css("#project_comments")
  # 
  #   find("#comments_link .count").should have_content("(0)")
  #   within "#project_comments" do
  #     all("#collection_list li").should have(0).items
  #     fill_in "Deixe seu comentário sobre este projeto", with: "My comment foo bar"
  #     click_on "Enviar comentário"
  #   end
  #   verify_translations
  # 
  #   find("#comments_link .count").should have_content("(1)")
  #   within "#project_comments" do
  #     all("#collection_list li").should have(1).items
  #     comment = find("#collection_list li")
  #     comment.find("a")[:href].should match(/\/users\/#{user.to_param}/)
  #     comment.find(".comment").text.should == "My comment foo bar"
  #   end
  # 
  # end

  # TODO: rewrite these specs once we have our new comments and updates systems
  # scenario "As a logged user, but not the project owner, I should not be able to post project updates" do
  # 
  #   fake_login
  #   
  #   project = Factory(:project)
  #   visit project_path(project)
  #   verify_translations
  #   
  #   click_link "Atualizações"
  #   page.should have_css("#project_updates")
  # 
  #   find("#updates_link .count").should have_content("(0)")
  #   within "#project_updates" do
  #     page.should have_no_css("form")
  #   end
  # 
  # end

  # TODO: rewrite these specs once we have our new comments and updates systems
  # scenario "As a project owner, I want to post project updates" do
  # 
  #   fake_login
  #   
  #   project = Factory(:project, user: user)
  #   visit project_path(project)
  #   verify_translations
  #   
  #   click_link "Atualizações"
  #   page.should have_css("#project_updates")
  # 
  #   find("#updates_link .count").should have_content("(0)")
  #   within "#project_updates" do
  #     all("#collection_list li").should have(0).items
  #     fill_in "Título da atualização", with: "My title"
  #     fill_in "Texto da atualização", with: "My text"
  #     click_on "Enviar atualização"
  #   end
  #   verify_translations
  # 
  #   find("#updates_link .count").should have_content("(1)")
  #   within "#project_updates" do
  #     all("#collection_list li").should have(1).items
  #     update = find("#collection_list li")
  #     update.find("h3").text.should == "My title"
  #     update.find(".comment").text.should == "My text"
  #   end
  # 
  # end

end
