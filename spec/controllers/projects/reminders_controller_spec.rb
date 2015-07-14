require 'rails_helper'

RSpec.describe Projects::RemindersController, type: :controller do
  let(:project) { create(:project) }

  subject{ response }

  before do
    allow(controller).to receive(:current_user).and_return(project.user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe "GET create" do
    before do
      get :create, { locale: :pt, id: project.id }
    end

    it "should create a reminder notification and redirects to project" do
      is_expected.to redirect_to(project_by_slug_path(project.permalink))
      expect(project.notifications.where(template_name: 'reminder', user_id: project.user.id).count).to eq(1)
    end
  end

  describe "DELETE destroy" do
    let(:reminder_at) { project.expires_at - 48.hours }

    before do
      project.notify_once(:reminder, project.user, project, {deliver_at: reminder_at})
      delete :destroy, { locale: :pt, id: project.id }
    end

    it "should delete the created reminder notification and redirects to project" do
      is_expected.to redirect_to(project_by_slug_path(project.permalink))
      expect(project.notifications.where(template_name: 'reminder', user_id: project.user.id).count).to eq(0)
    end
  end
end


