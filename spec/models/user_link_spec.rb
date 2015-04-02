require 'rails_helper'

RSpec.describe UserLink, :type => :model do
  let(:user){ create(:user) }

  describe ".link_without_protocol" do
    subject {UserLink.last.link_without_protocol}
    context "when link has no protocol" do
      before do
        create(:user_link, link: 'foo.com')
      end
      it{ is_expected.to eq('foo.com') }
    end
    context "when link has protocol" do
      before do
        create(:user_link, link: 'http://bar.com')
      end
      it{ is_expected.to eq('bar.com') }
    end
  end

end
