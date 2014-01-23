require 'spec_helper'

describe Users::ContributionsController do
  subject{ response }
  let(:user){ create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [create(:authorization, uid: 666, oauth_provider: create(:oauth_provider, name: 'facebook'))]) }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:successful_contribution){ create(:contribution, state: 'confirmed', project: successful_project) }
  let(:failed_contribution){ create(:contribution, state: 'confirmed', user: user, project: failed_project) }
  let(:other_contribution) { create(:contribution, project: failed_project) }
  let(:unconfirmed_contribution) { create(:contribution, state: 'pending', user: user, project: failed_project) }
  let(:current_user){ nil }
  let(:format){ 'json' }
  before do
    ::Configuration[:base_url] = 'http://catarse.me'
    controller.stub(:current_user).and_return(current_user)
    successful_contribution
    failed_contribution
    unconfirmed_contribution
    other_contribution
    successful_project.update_attributes state: 'successful'
    failed_project.update_attributes state: 'failed'
  end

  describe "GET index" do
    before do
      get :index, user_id: successful_contribution.user.id, locale: 'pt'
    end

    its(:status){ should == 200 }
  end

  describe "POST request_refund" do
    before do
      ContributionObserver.any_instance.stub(:notify_backoffice)
    end

    context "without user" do
      let(:current_user){ nil }
      before { post :request_refund, { user_id: user.id, id: failed_contribution.id } }

      it "should not set requested_refund" do
        failed_contribution.reload
        failed_contribution.requested_refund?.should be_false
      end
      it{ should redirect_to new_user_registration_path }
    end

    context "when current_user have a confirmed contribution" do
      let(:current_user) { user }
      before { post :request_refund, { user_id: user.id, id: failed_contribution.id } }

      it do
        failed_contribution.reload
        failed_contribution.requested_refund?.should be_true
      end

      it { should redirect_to user_path(current_user, anchor: 'credits') }
    end

    context "when current_user have a unconfirmed contribution" do
      let(:current_user) { user }
      before { post :request_refund, { user_id: user.id, id: unconfirmed_contribution.id } }

      it do
        unconfirmed_contribution.reload
        unconfirmed_contribution.requested_refund?.should be_false
      end

      it { should redirect_to user_path(current_user, anchor: 'credits') }
    end

    context "when current_user is not owner of the contribution" do
      let(:current_user) { create(:user) }
      let(:user) { other_contribution.user }
      before { post :request_refund, { user_id: user.id, id: other_contribution.id } }

      it do
        other_contribution.reload
        other_contribution.requested_refund?.should be_false
      end

      it { should redirect_to root_path }
    end
  end
end
