require 'rails_helper'

RSpec.describe ProjectPost, type: :model do
  describe "validations" do
    it{ is_expected.to validate_presence_of :project_id }
    it{ is_expected.to validate_presence_of :user_id }
    it{ is_expected.to validate_presence_of :comment }
    it{ is_expected.to validate_presence_of :comment_html }
  end

  describe "associations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :project }
  end

  describe ".create" do
    subject{ create(:project_post, comment: "this is a comment") }
    its(:comment_html){ should == "<p>this is a comment</p>\n" }
  end

  describe "#email_comment_html" do
    subject{ create(:project_post, comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_comment_html }
    it{ is_expected.to eq("<p>this is a comment<br/><a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a><br/><img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>\n") }
  end

end
