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

  describe ".for_non_contributors" do
    let(:project) { create(:project) }

    before do
      @exclusive_post = create(:project_post, exclusive: true, project: project)
      @post = create(:project_post, project: project)
    end

    subject { ProjectPost.for_non_contributors }

    it { should eq([@post]) }
  end



  describe ".create" do
    subject{ create(:project_post, comment: "this is a comment\n") }
    its(:comment_html){ should == "<p>this is a comment</p>" }
  end

  describe "#email_comment_html" do
    subject{ create(:project_post, comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_comment_html }
    it{ should == "<p>this is a comment<br />\n<a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a><br />\n<img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>" }
  end

  describe "#post_number" do
    let(:project){ create(:project) }
    let(:project_post){ create(:project_post, project: project) }
    subject{ project_post.post_number }
    before do
      create(:project_post, project: project)
      project_post
      create(:project_post, project: project)
    end
    it{ should == 2 }
  end

  describe "#notify_contributors" do
    before do
      Notification.unstub(:notify)
      Notification.unstub(:notify_once)
      @project = create(:project)
      contribution = create(:contribution, state: 'confirmed', project: @project)
      create(:contribution, state: 'confirmed', project: @project, user: contribution.user)
      @project.reload
      ActionMailer::Base.deliveries = []
      @post = ProjectPost.create!(user: @project.user, project: @project, title: "title", comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png")
      Notification.should_receive(:notify_once).with(
        :posts,
        contribution.user,
        {project_post_id: @post.id, user_id: contribution.user.id},
        {
          project: @post.project,
          project_post: @post,
          origin_email: @post.project.user.email,
          origin_name: @post.project.user.display_name
        }
      ).once.and_call_original
    end

    it 'should call Notification.notify once' do
      @post.notify_contributors
    end
  end
end
