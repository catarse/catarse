require 'spec_helper'

describe User do
  let(:user){ create(:user) }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:facebook_provider){ create :oauth_provider, name: 'facebook' }

  describe "associations" do
    it{ should have_many :contributions }
    it{ should have_many :projects }
    it{ should have_many :notifications }
    it{ should have_many :updates }
    it{ should have_many :unsubscribes }
    it{ should have_many :authorizations }
    it{ should have_many(:oauth_providers).through(:authorizations) }
    it{ should have_many :channels_subscribers }
    it{ should have_one :user_total }
    it{ should belong_to :channel }
    it{ should have_and_belong_to_many :subscriptions }
  end

  describe "validations" do
    before{ user }
    it{ should allow_value('foo@bar.com').for(:email) }
    it{ should_not allow_value('foo').for(:email) }
    it{ should_not allow_value('foo@bar').for(:email) }
    it{ should allow_value('a'.center(139)).for(:bio) }
    it{ should allow_value('a'.center(140)).for(:bio) }
    it{ should_not allow_value('a'.center(141)).for(:bio) }
    it{ should validate_uniqueness_of(:email) }
  end

  describe ".has_credits" do
    subject{ User.has_credits }

    context "when he has credits in the user_total" do
      before do
        b = create(:contribution, state: 'confirmed', value: 100, project: failed_project)
        failed_project.update_attributes state: 'failed'
        @u = b.user
        b = create(:contribution, state: 'confirmed', value: 100, project: successful_project)
      end
      it{ should == [@u] }
    end
  end

  describe ".has_not_used_credits_last_month" do
    subject{ User.has_not_used_credits_last_month }

    context "when he has used credits in the last month" do
      before do
        b = create(:contribution, state: 'confirmed', value: 100, credits: true)
        @u = b.user
      end
      it{ should == [] }
    end
    context "when he has not used credits in the last month" do
      before do
        b = create(:contribution, state: 'confirmed', value: 100, project: failed_project)
        failed_project.update_attributes state: 'failed'
        @u = b.user
      end
      it{ should == [@u] }
    end
  end

  describe ".by_payer_email" do
    before do
      p = create(:payment_notification)
      contribution = p.contribution
      @u = contribution.user
      p.extra_data = {'payer_email' => 'foo@bar.com'}
      p.save!
      p = create(:payment_notification, contribution: contribution)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
      p = create(:payment_notification)
      p.extra_data = {'payer_email' => 'another_email@bar.com'}
      p.save!
    end
    subject{ User.by_payer_email 'foo@bar.com' }
    it{ should == [@u] }
  end

  describe ".by_key" do
    before do
      b = create(:contribution)
      @u = b.user
      b.key = 'abc'
      b.save!
      b = create(:contribution, user: @u)
      b.key = 'abcde'
      b.save!
      b = create(:contribution)
      b.key = 'def'
      b.save!
    end
    subject{ User.by_key 'abc' }
    it{ should == [@u] }
  end

  describe ".by_id" do
    before do
      @u = create(:user)
      create(:user)
    end
    subject{ User.by_id @u.id }
    it{ should == [@u] }
  end

  describe ".by_name" do
    before do
      @u = create(:user, name: 'Foo Bar')
      create(:user, name: 'Baz Qux')
    end
    subject{ User.by_name 'Bar' }
    it{ should == [@u] }
  end

  describe ".by_email" do
    before do
      @u = create(:user, email: 'foo@bar.com')
      create(:user, email: 'another_email@bar.com')
    end
    subject{ User.by_email 'foo@bar' }
    it{ should == [@u] }
  end

  describe ".who_contributed_project" do
    subject{ User.who_contributed_project(successful_project.id) }
    before do
      @contribution = create(:contribution, state: 'confirmed', project: successful_project)
      create(:contribution, state: 'confirmed', project: successful_project, user: @contribution.user)
      create(:contribution, state: 'pending', project: successful_project)
    end
    it{ should == [@contribution.user] }
  end

  describe ".create_from_hash" do
    let(:auth)  do {
      'provider' => "facebook",
      'uid' => "foobar",
      'info' => {
        'name' => "Foo bar",
        'email' => 'another_email@anotherdomain.com',
        'nickname' => "foobar",
        'description' => "Foo bar's bio".ljust(200),
        'image' => "image.png"
      }
    }
    end
    subject{ User.create_from_hash(auth) }
    it{ should be_persisted }
    its(:email){ should == auth['info']['email'] }
  end

  describe ".create" do
    subject do
      User.create! do |u|
        u.email = 'diogob@gmail.com'
        u.password = '123456'
        u.twitter = '@dbiazus'
        u.facebook_link = 'facebook.com/test'
      end
    end
    its(:twitter){ should == 'dbiazus' }
    its(:facebook_link){ should == 'http://facebook.com/test' }
  end

  describe "#total_contributed_projects" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    subject { user.total_contributed_projects }

    before do
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user, project: project)
      create(:contribution, state: 'confirmed', user: user)
    end

    it { should == 2}
  end

  describe "#credits" do
    before do
      @u = create(:user)
      create(:contribution, state: 'confirmed', credits: false, value: 100, user_id: @u.id, project: successful_project)
      create(:contribution, state: 'confirmed', credits: false, value: 100, user_id: @u.id, project: unfinished_project)
      create(:contribution, state: 'confirmed', credits: false, value: 200, user_id: @u.id, project: failed_project)
      create(:contribution, state: 'confirmed', credits: true, value: 100, user_id: @u.id, project: successful_project)
      create(:contribution, state: 'confirmed', credits: true, value: 50, user_id: @u.id, project: unfinished_project)
      create(:contribution, state: 'confirmed', credits: true, value: 100, user_id: @u.id, project: failed_project)
      create(:contribution, state: 'requested_refund', credits: false, value: 200, user_id: @u.id, project: failed_project)
      create(:contribution, state: 'refunded', credits: false, value: 200, user_id: @u.id, project: failed_project)
      failed_project.update_attributes state: 'failed'
      successful_project.update_attributes state: 'successful'
    end

    subject{ @u.credits }

    it{ should == 50.0 }
  end

  describe "#update_attributes" do
    context "when I try to update moip_login" do
      before do
        user.update_attributes moip_login: 'test'
      end
      it("should perform the update"){ user.moip_login.should == 'test' }
    end
  end

  describe "#recommended_project" do
    subject{ user.recommended_projects }
    before do
      other_contribution = create(:contribution, state: 'confirmed')
      create(:contribution, state: 'confirmed', user: other_contribution.user, project: unfinished_project)
      create(:contribution, state: 'confirmed', user: user, project: other_contribution.project)
    end
    it{ should == [unfinished_project]}
  end

  describe "#updates_subscription" do
    subject{user.updates_subscription}
    context "when user is subscribed to all projects" do
      it{ should be_new_record }
    end
    context "when user is unsubscribed from all projects" do
      before { @u = create(:unsubscribe, project_id: nil, user_id: user.id )}
      it{ should == @u}
    end
  end

  describe "#project_unsubscribes" do
    subject{user.project_unsubscribes}
    before do
      @p1 = create(:project)
      create(:contribution, user: user, project: @p1)
      @u1 = create(:unsubscribe, project_id: @p1.id, user_id: user.id )
    end
    it{ should == [@u1]}
  end

  describe "#contributed_projects" do
    subject{user.contributed_projects}
    before do
      @p1 = create(:project)
      create(:contribution, user: user, project: @p1)
      create(:contribution, user: user, project: @p1)
    end
    it{should == [@p1]}
  end

  describe "#facebook_id" do
    subject{ user.facebook_id }
    context "when user have a FB authorization" do
      let(:user){ create(:user, authorizations: [ create(:authorization, uid: 'bar', oauth_provider: facebook_provider)]) }
      it{ should == 'bar' }
    end
    context "when user do not have a FB authorization" do
      let(:user){ create(:user) }
      it{ should == nil }
    end
  end

  describe "#fix_facebook_link" do
    subject{ user.facebook_link }
    context "when user provides invalid url" do
      let(:user){ create(:user, facebook_link: 'facebook.com/foo') }
      it{ should == 'http://facebook.com/foo' }
    end
    context "when user provides valid url" do
      let(:user){ create(:user, facebook_link: 'http://facebook.com/foo') }
      it{ should == 'http://facebook.com/foo' }
    end
  end

  describe "#made_any_contribution_for_this_project?" do
    let(:project) { create(:project) }
    subject { user.made_any_contribution_for_this_project?(project.id) }

    context "when user have contributions for the project" do
      before do
        create(:contribution, project: project, state: 'confirmed', user: user)
      end

      it { should be_true }
    end

    context "when user don't have contributions for the project" do
      it { should be_false }
    end
  end
end
