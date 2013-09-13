#encoding: utf-8
require 'spec_helper'

describe StaticController do

  render_views
  subject{ response }

  describe 'GET guidelines' do
    before{ get :guidelines, {locale: :pt} }
    it{ should be_success }
    its(:body){ should =~ /#{I18n.t('static.guidelines.title')}/ }
    its(:body){ should =~ /#{I18n.t('static.guidelines.subtitle')}/ }
  end

  describe "GET sitemap" do
    before{ get :sitemap, {locale: :pt} }
    it{ should be_success }
  end
  
  describe 'GET thank_you' do
    let(:backer) { FactoryGirl.create(:backer) }
    
    context 'with a session with backer' do
      before do
        request.session[:thank_you_backer_id] = backer.id
        get :thank_you, { locale: :pt } 
      end
      
      it{ should redirect_to(project_backer_path(backer.project, backer)) }
    end
    
    context 'without session' do
      it{ should be_successful }
    end
  end
end
