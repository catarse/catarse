require 'spec_helper'

describe Channels::Adm::Reports::SubscribersController do
  subject{ response }
  let(:channel){ create(:channel) }
  let(:admin) { create(:user, admin: false) }

  before do
    channel.trustees = [ admin ]
    controller.stub(:current_user).and_return(admin)
    request.stub(:subdomain).and_return(channel.permalink)
  end

  describe "GET index" do
    let(:user) { create(:user) }
    before do
      channel.subscribers = [ user ]
      get :index, locale: :pt, format: :csv
    end

    its(:body){ should == "name,email,url\n#{user.name},#{user.email},#{user_url(id: user.id)}\n" }
    its(:status){ should == 200 }
  end
end

