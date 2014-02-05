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

  describe ".for_non_contributors" do
    let(:project) { create(:project) }

    before do
      @exclusive_update = create(:update, exclusive: true, project: project)
      @update = create(:update, project: project)
    end

    subject { Update.for_non_contributors }

    it { should eq([@update]) }
  end



  describe ".create" do
    subject{ create(:update, comment: "this is a comment\n") }
    its(:comment_html){ should == "<p>this is a comment</p>" }
  end

  describe "#email_comment_html" do
    subject{ create(:update, comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png").email_comment_html }
    it{ should == "<p>this is a comment<br />\n<a href=\"http://vimeo.com/6944344\" target=\"_blank\">http://vimeo.com/6944344</a><br />\n<img src=\"http://catarse.me/assets/catarse/logo164x54.png\" alt=\"\" style=\"max-width:513px\" /></p>" }
  end

  describe "#update_number" do
    let(:project){ create(:project) }
    let(:update){ create(:update, project: project) }
    subject{ update.update_number }
    before do
      create(:update, project: project)
      update
      create(:update, project: project)
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
      @update = Update.create!(user: @project.user, project: @project, title: "title", comment: "this is a comment\nhttp://vimeo.com/6944344\nhttp://catarse.me/assets/catarse/logo164x54.png")
      Notification.should_receive(:notify_once).with(
        :updates,
        contribution.user,
        {update_id: @update.id, user_id: contribution.user.id},
        {
          project: @update.project,
          project_update: @update,
          origin_email: @update.project.user.email,
          origin_name: @update.project.user.display_name
        }
      ).once.and_call_original
    end

    it 'should call Notification.notify once' do
      @update.notify_contributors
    end
  end
end
