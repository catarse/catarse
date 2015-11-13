#encoding:utf-8
require 'rails_helper'

RSpec.describe FlexibleProjectsController, type: :controller do
  before{ allow(controller).to receive(:current_user).and_return(current_user) }
  before{ CatarseSettings[:base_url] = 'http://catarse.me' }
  before{ CatarseSettings[:email_projects] = 'foo@bar.com' }
  render_views
  subject{ response }
  let(:project){ create(:project, state: 'draft') }
  let!(:flexible_project) { create(:flexible_project, project: project, state: 'draft') }
  let(:current_user){ nil }

  describe "GET publish" do
    let(:current_user) { project.user }

    before do
      current_user.update_attributes({
        address_city: 'foo',
        address_state: 'MG',
        address_street: 'bar',
        address_number: '123',
        address_neighbourhood: 'MMs',
        address_zip_code: '000000',
        phone_number: '33344455333'
      })
      create(:reward, project: project)
      create(:bank_account, user: current_user)
      get :publish, id: flexible_project.id, locale: :pt
      flexible_project.reload
    end

    it { expect(flexible_project.open_for_contributions?).to eq(true) }
    it { expect(flexible_project.expires_at).to_not be_present }
  end

  describe "GET finish" do
    let(:current_user) { project.user }

    before do
      flexible_project.push_to_online
      get :finish, id: flexible_project.id, locale: :pt
      flexible_project.reload
    end

    it { expect(project.open_for_contributions?).to eq(true) }
    it { expect(project.expires_at).to be_nil }
  end

end
