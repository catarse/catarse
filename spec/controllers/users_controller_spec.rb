#encoding:utf-8
require 'spec_helper'

describe UsersController do
  render_views
  subject{ response }

  describe "User request refund" do
    before do
      @backer = Factory.create(:backer)
      @user = @backer.user
    end

    context "without user" do
      it 'should raise a exception' do
        lambda { 
          post :request_refund, { id: @user.id, back_id: @backer.id }
        }.should raise_exception CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end

    context "with user" do
      context "when current_user request to refund your backer" do
        before do
          request.session[:user_id]=@user.id
        end

        it "success requested" do
          @backer.can_refund = true
          @user.credits = 100
          @user.save
          @backer.save
          post :request_refund, { id: @user.id, back_id: @backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.index.refunded')
        end

        it "when user doesn't have a necessary value" do
          @user.credits = 4
          @user.save
          @user.reload
          post :request_refund, { id: @user.id, back_id: @backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.no_credits')
        end

        it "when backer cannot refunded" do
          @backer.update_attribute :refunded, true
          @backer.reload
          post :request_refund, { id: @user.id, back_id: @backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.refunded')
        end

        it "when backer already requested to refund" do
          @backer.update_attribute :requested_refund, true
          @backer.reload
          post :request_refund, { id: @user.id, back_id: @backer.id }

          ActiveSupport::JSON.decode(subject.body)['status'].should == I18n.t('credits.refund.requested_refund')
        end
      end
    end
  end
end
