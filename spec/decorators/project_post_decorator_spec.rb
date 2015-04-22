require 'rails_helper'

RSpec.describe ProjectPostDecorator do

  describe "#email_comment_html" do
    subject{ project_post.email_comment_html }
    context "when there is a video iframe" do
      let(:project_post){ create(:project_post, comment_html: '<iframe src="//www.foo.com"></iframe> <p>Bar</p>') }
      it{ is_expected.to eq('<a href="http://www.foo.com">www.foo.com</a> <p>Bar</p>') }
    end

    context "when there is no video iframe" do
      let(:project_post){ create(:project_post, comment_html: '<p>Bar</p>') }
      it{ is_expected.to eq('<p>Bar</p>') }
    end
  end

end

