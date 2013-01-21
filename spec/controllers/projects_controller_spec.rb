#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  before{ Notification.unstub(:create_notification) }
  before{ controller.stubs(:current_user).returns(current_user) }
  before{ ::Configuration[:base_url] = 'http://catarse.me' }
  render_views
  subject{ response }
  let(:project){ Factory(:project) }
  let(:current_user){ nil }

  describe "DELETE destroy" do
    before do
      delete :destroy, id: project.id, locale: :pt
    end

    context "when user is a guest" do
      it { Project.all.include?(project).should be_true }
    end

    context "when user is a project owner" do
      let(:current_user){ project.user }
      it { Project.all.include?(project).should be_true }
    end

    context "when user is a registered user" do
      let(:current_user){ Factory(:user, admin: false) }
      it { Project.all.include?(project).should be_true }
    end

    context "when user is an admin" do
      let(:current_user){ Factory(:user, admin: true) }
      it { Project.all.include?(project).should be_false }
    end
  end

  describe "GET index" do
    before do
      controller.stubs(:last_tweets).returns([])
      get :index, locale: :pt
    end
    it { should be_success }
  end

  describe "GET new" do
    before { get :new, locale: :pt }

    context "when user is a guest" do
      it { should_not be_success }
    end

    context "when user is a registered user" do
      let(:current_user){ Factory(:user, admin: false) }
      it { should be_success }
    end
  end

  describe "PUT update" do
    shared_examples_for "updatable project" do
      before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
      it { 
        project.reload
        project.name.should == 'My Updated Title' 
      }
    end

    shared_examples_for "protected project" do
      before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
      it { 
        project.reload
        project.name.should == 'Foo bar' 
      }
    end

    context "when user is a guest" do
      it_should_behave_like "protected project"
    end

    context "when user is a project owner" do
      let(:current_user){ project.user }

      context "when project is offline" do
        it_should_behave_like "updatable project"
      end

      context "when project is online" do
        let(:project) { Factory(:project, permalink: nil, state: 'online') }

        before do
          controller.stubs(:current_user).returns(project.user)
        end

        context "when I try to update the project name and the about field" do
          before{ put :update, id: project.id, project: { name: 'new_title', about: 'new_description' }, locale: :pt }
          it "should not update neither" do
            project.reload
            project.name.should_not == 'new_title'
            project.about.should_not == 'new_description'
          end
        end

        context "when I try to update only the about field" do
          before{ put :update, id: project.id, project: { about: 'new_description' }, locale: :pt }
          it "should update it" do
            project.reload
            project.about.should == 'new_description'
          end
        end
      end
    end

    context "when user is a registered user" do
      let(:current_user){ Factory(:user, admin: false) }
      it_should_behave_like "protected project"
    end

    context "when user is an admin" do
      let(:current_user){ Factory(:user, admin: true) }
      it_should_behave_like "updatable project"
    end
  end

  describe "GET embed" do
    before do
      get :embed, :id => project, :locale => :pt 
    end
    its(:status){ should == 200 }
  end

  describe "GET show" do
    context "when we have update_id in the querystring" do
      let(:project){ Factory(:project, :permalink => nil) }
      let(:update){ Factory(:update, :project => project) }
      before{ get :show, :id => project, :update_id => update.id, :locale => :pt }
      it("should assign update to @update"){ assigns(:update).should == update }
    end

    context "when we have permalink and do not pass permalink in the querystring" do
      let(:project){ Factory(:project, :permalink => 'test') }
      before{ get :show, :id => project, :locale => :pt }
      it{ should redirect_to project_by_slug_path(project.permalink) }
    end

    context "when we do not have permalink and do not pass permalink in the querystring" do
      let(:project){ Factory(:project, :permalink => nil) }
      before{ get :show, :id => project, :locale => :pt }
      it{ should be_success }
    end
  end
end
