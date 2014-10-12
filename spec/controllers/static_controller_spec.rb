#encoding: utf-8
require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  render_views
  subject{ response }

  describe 'GET thank_you' do
    let(:contribution) { FactoryGirl.create(:contribution) }

    context 'with a session with contribution' do
      before do
        request.session[:thank_you_contribution_id] = contribution.id
        get :thank_you, { locale: :pt }
      end

      it{ is_expected.to redirect_to(project_contribution_path(contribution.project, contribution)) }
    end

    context 'without session' do
      it{ is_expected.to be_successful }
    end
  end
end
