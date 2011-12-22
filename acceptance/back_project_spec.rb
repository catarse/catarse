# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Back project" do

  include Rails.application.routes.url_helpers
  
  before do
    @project = Factory(:project, visible: true)
    @rewards = [
      Factory(:reward, project: @project, minimum_value: 10, description: "$10 reward"),
      Factory(:reward, project: @project, minimum_value: 20, description: "$20 reward"),
      Factory(:reward, project: @project, minimum_value: 30, description: "$30 reward")
    ]
    # Create a state to select
    State.create! name: "Foo bar", acronym: "FB"
  end

  scenario "As an unlogged user, before I back a project I need to be asked to log in" do
    
    visit project_path(@project)
    verify_translations
  
    click_on "Quero apoiar este projeto"
    verify_translations
    find("#login").visible?.should be_true
    click_link 'X'
    verify_translations
    find("#login").visible?.should be_false
    
    find("#rewards li.clickable").click
    verify_translations
    # Had to add a sleep for the tests to pass on Travis-CI
    sleep 2
    find("#login").visible?.should be_true
    
  end
  
  scenario "As a user without credits, I want to back a project by entering the value and selecting no reward" do
  
    fake_login
    
    visit project_path(@project)
    verify_translations
  
    click_on "Quero apoiar este projeto"
    verify_translations
    current_path.should == new_project_backer_path(@project)
    
    fill_in "Com quanto você quer apoiar?", with: "10"
    
    click_on "Revisar e realizar pagamento"
    verify_translations
    current_path.should == review_project_backers_path(@project)
    page.should have_content("Você irá apoiar com R$ 10 e não quer nenhuma recompensa por seu apoio.")
    
  end
  
  scenario "As a user without credits, I want to back a project by clicking on the reward on the back project page, and pay using PayPal" do
    
    class FakeResponse
      def redirect_uri
        "http://www.paypal.com"
      end
    end
  
    class FakeRequest
      def setup(*args)
        FakeResponse.new
      end
    end
    
    Configuration.create!(name: "paypal_username", value: "foobar")
    Configuration.create!(name: "paypal_password", value: "foobar")
    Configuration.create!(name: "paypal_signature", value: "foobar")
    Paypal::Express::Request.stubs(:new).returns(FakeRequest.new)
    Paypal::Express::Request.stubs(:setup).returns(FakeResponse.new)
  
    fake_login
    
    visit project_path(@project)
    verify_translations
  
    click_on "Quero apoiar este projeto"
    verify_translations
    current_path.should == new_project_backer_path(@project)
    
    fill_in "Com quanto você quer apoiar?", with: "10"
  
    choose "backer_reward_id_#{@rewards[2].id}"
    find("#backer_value")[:value].should == "30"
    choose "backer_reward_id_#{@rewards[1].id}"
    find("#backer_value")[:value].should == "30"
    choose "backer_reward_id_#{@rewards[0].id}"
    find("#backer_value")[:value].should == "30"
    choose "backer_reward_id_0"
    find("#backer_value")[:value].should == "30"
    
    fill_in "Com quanto você quer apoiar?", with: "10"
    choose "backer_reward_id_#{@rewards[1].id}"
    find("#backer_value")[:value].should == "20"
  
    Backer.count.should == 0
  
    click_on "Revisar e realizar pagamento"
    verify_translations
    current_path.should == review_project_backers_path(@project)
    page.should have_content("Você irá apoiar com R$ 20 e ganhará a seguinte recompensa: $20 reward")
    
    Backer.count.should == 1
    backer = Backer.first
    backer.payment_method.should == "MoIP"
  
    within "#international_payment" do
      
      click_on "Clique aqui"
      verify_translations
      find("#international_submit")[:disabled].should == "true"
      check "Eu li e estou de acordo com os termos de uso."
      find("#international_submit")[:disabled].should == "false"
      click_on "Efetuar pagamento pelo PayPal"
      
    end
    
    current_url.should match(/paypal\.com/)
    backer.reload
    backer.payment_method.should == "PayPal"
    
    visit thank_you_path
    verify_translations
    
    within 'head title' do
      page.should have_content("Muito obrigado")
    end
  
    within '#content_header' do
      within 'h1' do
        page.should have_content("Muito obrigado")
      end
    end
    
    page.should have_content "Você agora é parte do grupo que faz de tudo para o #{@project.name} acontecer."
    
  end
  
  scenario "As a user without credits, I want to back a project by clicking on a reward on the project page, and pay using MoIP", :now => true do
  
    MoIP::Client.stubs(:checkout).returns({"Token" => "foobar"})
    MoIP::Client.stubs(:moip_page).returns("http://www.moip.com.br")
  
    fake_login
    
    visit project_path(@project)
    verify_translations
  
    within "#rewards ul" do
      rewards = all("li.clickable")
      rewards[2].find("input[type=hidden]")[:value].should == "#{new_project_backer_path(@project)}/?reward_id=#{@rewards[2].id}"
      rewards[2].click
    end
  
    verify_translations
    
    find("#backer_reward_id_#{@rewards[2].id}")[:checked].should == "true"
    find("#backer_value")[:value].should == "30"
    
    Backer.count.should == 0
    
    click_on "Revisar e realizar pagamento"
    verify_translations
    current_path.should == review_project_backers_path(@project)
    page.should have_content("Você irá apoiar com R$ 30 e ganhará a seguinte recompensa: $30 reward")
    
    Backer.count.should == 1
    backer = Backer.first
    backer.payment_method.should == "MoIP"
  
    # Disabling jQuery mask, because we cannot test it with Capybara
    page.evaluate_script('jQuery.mask = function() { return true; }')
    
    fill_in "Nome completo", with: "Foo bar"
    fill_in "Email", with: "foo@bar.com"
    fill_in "CPF", with: "815.587.240-87"
    fill_in "CEP", with: "90050-004"
    
    # Sleep to wait for the loading of zip code data
    sleep 2
    
    fill_in "Número", with: "1010"
    fill_in "Complemento", with: "10"
    fill_in "Bairro", with: "Foo bar"
    fill_in "Cidade", with: "Foo bar"
    select "Foo bar", from: "Estado"
    fill_in "Telefone celular", with: "(99)9999-9999"
    
    page.should have_css("#user_full_name.ok")
    page.should have_css("#user_email.ok")
    page.should have_css("#user_cpf.ok")
    page.should have_css("#user_address_zip_code.ok")
    page.should have_css("#user_address_street.ok")
    page.should have_css("#user_address_number.ok")
    page.should have_css("#user_address_complement.ok")
    page.should have_css("#user_address_neighbourhood.ok")
    page.should have_css("#user_address_city.ok")
    page.should have_css("#user_address_state.ok")
    page.should have_css("#user_phone_number.ok")
  
    find("#user_submit")[:disabled].should == "true"
    check "Eu li e estou de acordo com os termos de uso."
    find("#user_submit")[:disabled].should == "false"
    click_on "Efetuar pagamento pelo MoIP"
  
    current_url.should match(/moip\.com\.br/)
    backer.reload
    backer.payment_method.should == "MoIP"
    
  end
  
  scenario "As a user with credits, I want to back a project using my credits" do
  
    fake_login
    user.update_attribute :credits, 10
    
    visit project_path(@project)
    verify_translations
  
    click_on "Quero apoiar este projeto"
    verify_translations
    current_path.should == new_project_backer_path(@project)
    
    fill_in "Com quanto você quer apoiar?", with: "10"
    check "Quero usar meus créditos para este apoio."
  
    Backer.count.should == 0
  
    click_on "Revisar e realizar pagamento"
    verify_translations
  
    Backer.count.should == 1
    backer = Backer.first
    backer.payment_method.should == "MoIP"
  
    current_path.should == review_project_backers_path(@project)
    page.should have_content("Você irá apoiar com R$ 10 e não quer nenhuma recompensa por seu apoio.")
    page.should have_content("Este apoio será pago com seus créditos. Após a confirmação, você ficará com um saldo de R$ 0 em créditos para apoiar outros projetos.")
    
    find("#user_submit")[:disabled].should == "true"
    check "Eu li e estou de acordo com os termos de uso."
    find("#user_submit")[:disabled].should == "false"
    click_on "Confirmar apoio com créditos"
  
    current_path.should == thank_you_path
    backer.reload
    backer.payment_method.should == "Credits"
    backer.confirmed.should == true
    user.reload
    user.credits.should == 0
        
  end
  
  scenario "As a user, I want to back a project anonymously" do
    
    fake_login
    user.update_attribute :credits, 10
    
    visit project_path(@project)
    verify_translations
  
    click_on "Quero apoiar este projeto"
    verify_translations
    
    fill_in "Com quanto você quer apoiar?", with: "10"
    check "Quero usar meus créditos para este apoio."
  
    check "Quero que meu apoio seja anônimo."
  
    Backer.count.should == 0
  
    click_on "Revisar e realizar pagamento"
    verify_translations
  
    Backer.count.should == 1
    backer = Backer.first
    backer.anonymous.should == true
        
  end
  
  scenario "I should not be able to access /thank_you if I not backed a project" do
  
    fake_login
    visit thank_you_path
    verify_translations
    
    current_path.should == root_path
    page.should have_css('.failure.wrapper')
  
  end
  
end
