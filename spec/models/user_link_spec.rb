require 'rails_helper'

RSpec.describe UserLink, :type => :model do
  let(:user){ create(:user) }
  let(:user_link){ create(:user_link, link: link) }

  describe ".link_without_protocol" do
    subject{ user_link.without_protocol}
    context "when link has no protocol" do
      let(:link){ 'foo.com' }
      it{ is_expected.to eq('foo.com') }
    end
    context "when link has protocol" do
      let(:link){ 'http://bar.com' }
      it{ is_expected.to eq('bar.com') }
    end
  end

end
