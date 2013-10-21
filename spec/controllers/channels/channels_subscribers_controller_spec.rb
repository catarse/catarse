require 'spec_helper'

describe Channels::ChannelsSubscribersController do
  subject{ response }
  let(:channel_subscriber){ nil }
  let(:channel){ FactoryGirl.create(:channel) }
  let(:user){ FactoryGirl.create(:user) }
  let(:current_user){ user }

  before do
    request.stub(:subdomain).and_return(channel.permalink)
    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET show" do
    before do
      channel_subscriber
      get :show
    end

    context "when user is signed in" do 
      it{ should redirect_to root_path }
    end

    context "when no user is signed in" do 
      let(:current_user){ nil }
      it{ should redirect_to new_user_registration_path }
    end
  end

  describe "DELETE destroy" do
    let(:channel_subscriber){ ChannelsSubscriber.create!(channel: channel, user: user) }
    before do
      delete :destroy, id: channel_subscriber.id
    end

    context "when signed in user owns the subscription" do
      it{ should redirect_to root_path }
    end

    context "when signed in user does not own the subscription" do
      let(:current_user){ FactoryGirl.create(:user) }
      it{ should_not be_successful }
    end
  end
end

