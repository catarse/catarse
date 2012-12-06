#encoding:utf-8
require 'spec_helper'

describe ProjectsController do
  before {Notification.unstub(:create_notification)}
  render_views
  subject{ response }

  shared_examples_for "GET projects index/show" do
    before { get :show, id: project.id, locale: :pt}
    it { should be_success }
  end

  shared_examples_for "GET projects new" do
    before { get :new, locale: :pt }
    it { should be_success }
  end

  shared_examples_for "GET projects new without permission" do
    before { get :new, locale: :pt }
    it { should_not be_success }
  end

  shared_examples_for "PUT projects update" do
    before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
    it { 
      project.reload
      project.name.should == 'My Updated Title' 
    }
  end

  shared_examples_for "PUT projects update without permission" do
    before { put :update, id: project.id, project: { name: 'My Updated Title' },locale: :pt }
    it { 
      project.reload
      project.name.should == 'Foo bar' 
    }
  end

  shared_examples_for "DELETE projects destroy" do
    before { delete :destroy, id: project.id, locale: :pt }
    it { Project.all.include?(project).should be_false }
  end

  shared_examples_for "DELETE projects destroy without permission" do
    before { delete :destroy, id: project.id, locale: :pt }
    it { Project.all.include?(project).should be_true }
  end


  context "When current_user is a guest" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(nil)
    end

    it_should_behave_like "GET projects index/show"
    it_should_behave_like "GET projects new without permission"
    it_should_behave_like "PUT projects update without permission"
    it_should_behave_like "DELETE projects destroy without permission"
  end

  context "When current_user is a project owner" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(project.user)
    end

    it_should_behave_like "GET projects index/show"
    it_should_behave_like "GET projects new"
    it_should_behave_like "PUT projects update"
    it_should_behave_like "DELETE projects destroy without permission"
  end

  context "When current_user is admin" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(Factory(:user, admin: true))
    end

    it_should_behave_like "GET projects index/show"
    it_should_behave_like "GET projects new"
    it_should_behave_like "PUT projects update"
    it_should_behave_like "DELETE projects destroy"
  end

  context "When current_user is a registered user" do
    let(:project) { Factory(:project, permalink: nil) } 

    before do
      controller.stubs(:current_user).returns(Factory(:user, admin: false))
    end

    it_should_behave_like "GET projects index/show"
    it_should_behave_like "GET projects new"
    it_should_behave_like "PUT projects update without permission"
    it_should_behave_like "DELETE projects destroy without permission"
  end

  context "When project is online" do
    let(:project) { Factory(:project, permalink: nil, state: 'online') }

    before do
      controller.stubs(:current_user).returns(project.user)
    end

    it "is not updated when pass attributes that is not allowed to update in some states" do
      put :update, id: project.id, project: { name: 'new_title', about: 'new_description' }, locale: :pt
      project.reload
      project.about.should == 'Foo bar'
    end

    it "owner can update only about the project" do
      put :update, id: project.id, project: { about: 'new_description' }, locale: :pt
      project.reload
      project.about.should == 'new_description'
    end
  end

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

  describe "POST send_mail" do
    let(:project){ Factory(:project) }
    Factory(:notification_type, :name => 'project_received')
    let(:name){ project.name }
    let(:user){ project.user }

    before do
      controller.stubs(:current_user).returns(user)
      Notification.expects(:create_notification).with(:project_received, user)
      post :send_mail, :locale => :pt
    end

    it{ should redirect_to root_path }
  end
end
