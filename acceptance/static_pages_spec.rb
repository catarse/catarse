# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Static Pages Feature", :driver => :selenium do

  scenario "I visit the guidelines page" do

    visit homepage
    click_link 'Como funciona'
    verify_translations
    current_path.should == guidelines_path

    within 'head title' do
      page.should have_content("Como funciona o Catarse?")
    end

    within '.title' do
      within 'h1' do
        page.should have_content("Como funciona o Catarse?")
      end
    end

  end

  scenario "I visit the FAQ page" do

    visit homepage
    click_link 'F.A.Q./Ajuda'
    verify_translations
    current_path.should == faq_path

    within 'head title' do
      page.should have_content("Perguntas frequentes")
    end

    within '.title' do
      within 'h1' do
        page.should have_content("Perguntas frequentes")
      end
    end

  end

  scenario "I visit the terms of use page" do

    visit homepage
    click_link 'Termos de Uso'
    verify_translations
    current_path.should == terms_path

    within 'head title' do
      page.should have_content("Termos de uso")
    end

    within '.title' do
      within 'h1' do
        page.should have_content("Termos de uso")
      end
    end

  end

  scenario "I visit the privacy policy page" do

    visit homepage
    click_link 'Política de Privacidade'
    verify_translations
    current_path.should == privacy_path

    within 'head title' do
      page.should have_content("Política de privacidade")
    end

    within '.title' do
      within 'h1' do
        page.should have_content("Política de privacidade")
      end
    end

  end

end
