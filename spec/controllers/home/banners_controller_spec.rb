require 'rails_helper'

RSpec.describe Home::BannersController, type: :controller do
    let(:home_banner) { create(:home_banner) }

    describe 'GET index' do

        it 'should get all banners' do
            get :index
            expect(response.status).to eq(200)
        end
    end

    describe 'PUT banner' do
        let(:banner) do
            { :title => 'title2', :subtitle => 'subtitle' }
        end

        let(:admin) { create(:user, admin: true) }
        let(:current_user) { admin }

        before do
            allow(controller).to receive(:current_user).and_return(admin)
            put :update, params: { id: home_banner.id, banner: banner }
        end

        it 'should update banner' do
            expect(response.status).to eq(200)
        end
    end
end
