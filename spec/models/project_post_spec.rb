require 'rails_helper'

RSpec.describe ProjectPost, type: :model do
  describe "validations" do
    it{ is_expected.to validate_presence_of :project_id }
    it{ is_expected.to validate_presence_of :user_id }
    it{ is_expected.to validate_presence_of :comment_html }
    it{ is_expected.to validate_presence_of :title }
  end

  describe "associations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to belong_to :project }
  end

  describe ".create" do
    subject{ create(:project_post, comment_html: "this is a comment") }
    its(:comment_html){ should == "this is a comment" }
  end

end
