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

  describe "#notify_backers" do
    before do
      Notification.unstub(:create_notification)
      Factory(:notification_type, :name => 'updates')
      @project = Factory(:project)
      backer = Factory(:backer, :confirmed => true, :project => @project)
      Factory(:backer, :confirmed => true, :project => @project, :user => backer.user)
      @project.reload
      ActionMailer::Base.deliveries = []
      @update = Update.create!(:user => @project.user, :project => @project, :comment => "this is a comment")
      Notification.expects(:create_notification).with(:updates, backer.user,
        :project_name => backer.project.name,
        :project_owner => backer.project.user.display_name,
        :update_title => @update.title,
        :update => @update,
        :update_comment => @update.comment_html.gsub(/width="560" height="340"/, 'width="500" height="305"')).once
    end

    it 'should call Notification.create_notification once' do
      @update.notify_backers
    end
  end
end
