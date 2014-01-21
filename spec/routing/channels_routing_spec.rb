require "spec_helper"

describe Channels::ProfilesController do
  describe :routing do
    context "no environment variable" do
      it { expect(get("http://subdomain.domain.com/")).to route_to("channels/profiles#show") }
    end
    context "environment variable set" do
      it { expect(get("http://www.domain.com/")).to route_to("projects#index") }
    end
  end
end
