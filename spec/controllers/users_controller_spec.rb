#encoding:utf-8
require 'spec_helper'

describe UsersController do
  render_views
  subject{ response }

  let(:successful_project){ Factory(:project, :finished => true, :successful => true) }
  let(:failed_project){ Factory(:project, :finished => true, :successful => false) }
  let(:backer){ Factory(:backer, :user => user, :project => failed_project) }
  let(:user){ Factory(:user, :provider => 'facebook', :uid => '666') }

  describe "PUT update" do
    before do
      request.session[:user_id] = user.id
      put :update, :id => user.id, :locale => 'pt', :twitter => 'test'
    end
    it{ should redirect_to user_path(user, :anchor => 'settings') }
  end

  describe "GET show" do
    before do
      Factory(:notification_type, name: 'updates')
      request.session[:user_id] = user.id
      get :show, :id => user.id, :locale => 'pt'
    end

    it{ assigns(:fb_admins).should include(user.facebook_id.to_i) }
  end

  describe "POST unsubscribe_update" do
    before do
      request.session[:user_id] = user.id
      @project = Factory(:project)
      @notification_type = Factory(:notification_type, name: 'updates')
    end

    context "when we already have such unsubscribe" do
      before do
        uns = Factory(:unsubscribe, project_id: @project.id, user_id: user.id, notification_type_id: @notification_type.id)
        put :unsubscribe_update, id: user.id, locale: 'pt', user: { unsubscribes_attributes: {'0' => {subscribed:'1', id: uns.id, project_id: @project.id, user_id: user.id, notification_type_id: @notification_type.id}}}
      end
      it("should destroy the unsubscribe"){ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 0 }
    end

    context "when we do not have such unsubscribe" do
      before do
        put :unsubscribe_update, id: user.id, locale: 'pt', user: { unsubscribes_attributes: {'0' => {subscribed:'0', project_id: @project.id, user_id: user.id, notification_type_id: @notification_type.id}}}
      end
      it("should create an unsubscribe"){ Unsubscribe.where(:user_id => user.id, :project_id => @project.id).count.should == 1 }
    end
  end

  describe "POST request_refund" do
    context "without user" do
      it 'should raise a exception' do
        lambda {
          post :request_refund, { id: user.id, back_id: backer.id }
        }.should raise_exception CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end

    context "with user" do
      context "when current_user request to refund your backer" do
        before do
          request.session[:user_id]=user.id
        end

        it "success requested" do
          post :request_refund, { id: user.id, back_id: backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.index.refunded')
        end

        it "when user doesn't have a necessary value" do
          Factory(:backer, :user => user, :project => successful_project, :credits => true)
          post :request_refund, { id: user.id, back_id: backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.no_credits')
        end

        it "when backer cannot refunded" do
          backer.update_attributes({ refunded: true })
          backer.reload
          post :request_refund, { id: user.id, back_id: backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.refunded')
        end

        it "when backer already requested to refund" do
          backer.update_attributes({ requested_refund: true })
          backer.reload
          post :request_refund, { id: user.id, back_id: backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.requested_refund')
        end
      end
    end
  end
end
