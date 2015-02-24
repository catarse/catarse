require 'rails_helper'

RSpec.describe MixpanelObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:people){ double('mixpanel-ruby people', {set: nil}) }
  let(:tracker){ double('mixpanel-ruby tracker', {track: nil, people: people}) }
  let(:properties) do
    {
      user_id: contribution.user.id.to_s,
      created: contribution.user.created_at,
      last_login: contribution.user.last_sign_in_at,
      contributions: contribution.user.total_contributed_projects,
      has_contributions: (contribution.user.total_contributed_projects > 0),
      created_projects: contribution.user.projects.count,
      has_online_project: contribution.user.has_online_project?,
      project: contribution.project.name,
      payment_method: contribution.payment_method,
      payment_choice: contribution.payment_choice,
      referral: contribution.referal_link
    }
  end

  let(:project){ create(:project, state: 'online') }
  let(:project_owner_properties) do
    user = project.user
    {
      user_id: user.id.to_s,
      created: user.created_at,
      last_login: user.last_sign_in_at,
      contributions: user.total_contributed_projects,
      has_contributions: (user.total_contributed_projects > 0),
      created_projects: user.projects.count,
      has_online_project: user.has_online_project?
    }
  end

  before do
    allow_any_instance_of(MixpanelObserver).to receive(:tracker).and_call_original
    allow_any_instance_of(MixpanelObserver).to receive_messages(tracker: tracker)
  end

  describe "#from_waiting_confirmation_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'), contribution.user.current_sign_in_ip)
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", properties, contribution.user.current_sign_in_ip)
      contribution.notify_observers :from_waiting_confirmation_to_confirmed
    end
  end

  describe "#from_pending_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'), contribution.user.current_sign_in_ip)
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", properties, contribution.user.current_sign_in_ip)
      contribution.notify_observers :from_pending_to_confirmed
    end
  end

  describe "#after_save" do
    context "when we create a Reward" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated reward"), project.user.current_sign_in_ip)
        create(:reward, project: project)
      end
    end

    context "when we create a ProjectBudget" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated budget"), project.user.current_sign_in_ip)
        create(:project_budget, project: project)
      end
    end
  end

  describe "#after_create" do
    context "when we create a ProjectPost" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Created post"), project.user.current_sign_in_ip)
        create(:project_post, project: project)
      end
    end
  end

  describe "#after_update" do
    [:video_url, :about, :headline, :uploaded_image].each do |attribute|
      context "when we update a project's #{attribute}" do
        it "should send tracker a track call with the change" do
          expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated #{attribute}"), project.user.current_sign_in_ip)
          project.update_attributes attribute => 'http://youtu.be/teste'
        end
      end
    end


    context "when we update a project owner profile" do
      let(:user){ project.user }
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated profile"), project.user.current_sign_in_ip)
        expect(people).to receive(:set).with(user.id.to_s, project_owner_properties.merge(action: "Updated profile"), project.user.current_sign_in_ip)
        user.update_attributes bio: 'test'
      end
    end
  end

end


