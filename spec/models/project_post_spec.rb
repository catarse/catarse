require 'spec_helper'

describe ProjectPost do
  describe "validations" do
    it{ should validate_presence_of :project_id }
    it{ should validate_presence_of :user_id }
    it{ should validate_presence_of :comment }
    it{ should validate_presence_of :comment_html }
  end

  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
  end

  describe ".create" do
    subject{ create(:project_post, comment: "this is a comment\n") }
    its(:comment_html){ should == "<p>this is a comment</p>" }
  end

  describe "#email_comment_html" do
    subject{ create(:project_post, comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_comment_html }
    it{ should == "<p>this is a comment<br />\n<a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a><br />\n<img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>" }
  end

end
