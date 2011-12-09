#encoding:utf-8
require 'spec_helper'

describe CreditsController do
  render_views

  before(:each) do
    @user = create(:user)
  end

  describe "Credit index" do
    context "with current user" do
      context "user without credits" do
        it "should display message that not have credits" do
          request.session[:user_id]=@user.id
          get :index, {:locale => :pt}

          response.should render_template("credits/index")
          response.should be_success
          response.body.should =~ /#{I18n.t('credits.index.no_refunds')}/
        end
      end

      context "user with credits" do
        before(:each) do
          @backer = create(:backer, :user => @user, :value => 100, :can_refund => true, :refunded => false)
          @user.update_attribute(:credits, 100)
        end

        it "should render template" do
          request.session[:user_id]=@user.id
          get :index, {:locale => :pt}

          response.should render_template("credits/index")
          response.should be_success
          response.body.should =~ /R\$ 100/
        end

        context "when user refund" do
          context "user have more backers" do
            before(:each) do
              @backer_01 = create(:backer, :user => @user, :value => 20, :can_refund => true, :refunded => false)
              @user.update_attribute(:credits, 120)
            end

            it "should view the backers values" do
              request.session[:user_id]=@user.id
              get :index, {:locale => :pt}
              response.body.should =~ /R\$ 100/
              response.body.should =~ /R\$ 20/
            end

            it "when i request refund" do
              request.session[:user_id]=@user.id
              post :refund, {:locale => :pt, :backer_id => @backer.id}
              @backer.reload
              @user.reload

              @backer.requested_refund.should be_true
              @user.credits.to_i.should == 20
              response.body.should =~ /R\$ 20/
            end
          end
        end

        # it "should send emails when user request refund" do
        #   request.session[:user_id]=@user.id
        #   post :refund, {:locale => :pt, :backer_id => @backer.id}
        #
        #   ActionMailer::Base.deliveries.should_not be_empty
        # end
      end
    end

    context "without current user" do
      it "redirect" do
        request.session[:user_id]=nil
        get :index, {:locale => :pt}

        response.should be_redirect
      end
    end
  end
end