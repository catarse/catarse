#encoding: utf-8
require 'spec_helper'

describe StaticController do
  render_views
  subject{ response }
  
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
