require 'rails_helper'

RSpec.describe Channels::Admin::Reports::SubscriberReportsController, type: :controller do
  subject{ response }
  let(:channel){ create(:channel) }
  let(:admin) { create(:user, admin: false) }

  before do
    admin.channel = channel
    allow(controller).to receive(:current_user).and_return(admin)
    allow(request).to receive(:subdomain).and_return(channel.permalink)
  end

  describe "GET index" do
    let(:user) { create(:user) }
    before do
      channel.subscribers = [ user ]
      get :index, locale: :pt, format: :csv
    end

    it{ is_expected.to be_successful }
  end
end

