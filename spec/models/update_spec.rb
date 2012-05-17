require 'spec_helper'

describe Update do
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
    subject{ Update.create!(:user => Factory(:user), :project => Factory(:project), :comment => "this is a comment\n") }
    its(:comment_html){ should == "<p>this is a comment</p>" }
  end
end
