require 'rails_helper'

RSpec.describe UnsubscribesController, type: :controller do
  subject{ response }

  describe "POST create" do
    let(:user){ FactoryGirl.create(:user) }
    before do
      request.session[:user_id] = user.id
      @project = create(:project)
    end

    context "when we already have such unsubscribe" do
      before do
        create(:unsubscribe, project_id: @project.id, user_id: user.id)
        unsub = create(:unsubscribe, project_id: @project.id, user_id: user.id)
        post :create, user_id: user.id, locale: 'pt', user: { unsubscribes_attributes: {'1' => {subscribed:'1', id: unsub.id, project_id: @project.id, user_id: user.id}}}
      end
      it("should destroy the unsubscribe"){ expect(Unsubscribe.where(user_id: user.id, project_id: @project.id).count).to eq(0) }
    end

    context "when we do not have such unsubscribe" do
      before do
        post :create, user_id: user.id, locale: 'pt', user: { unsubscribes_attributes: {'1' => {subscribed:'0', project_id: @project.id, user_id: user.id}}}
      end
      it("should create an unsubscribe"){ expect(Unsubscribe.where(user_id: user.id, project_id: @project.id).count).to eq(1) }
    end
  end

end
