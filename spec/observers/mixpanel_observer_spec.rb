require 'rails_helper'

RSpec.describe MixpanelObserver do
  let(:contribution){ create(:confirmed_contribution) }
  let(:payment){ contribution.payments.first }
  let(:people){ double('mixpanel-ruby people', {set: nil}) }
  let(:tracker){ double('mixpanel-ruby tracker', {track: nil, people: people}) }
  let(:properties) do
    contribution.user.to_analytics.merge(
      contribution.project.to_analytics.merge(
        {
          payment_method: payment.try(:gateway),
          payment_choice: payment.payment_method,
          referral: contribution.referral_link,
          anonymous: contribution.anonymous,
          value: contribution.value,
          reward_id: contribution.reward_id,
          reward_value: contribution.reward.try(:minimum_value)
        }
      )
    )
  end

  let(:project){ create(:project, state: 'online') }
  let(:project_owner_properties) do
    project.user.to_analytics
  end

  before do
    allow_any_instance_of(MixpanelObserver).to receive(:tracker).and_call_original
    allow_any_instance_of(MixpanelObserver).to receive_messages(tracker: tracker)
  end

  describe "#from_pending_to_paid" do
    it "should send tracker a track call with the user id of the contribution" do
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'), contribution.user.current_sign_in_ip)
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", properties, contribution.user.current_sign_in_ip)
      payment.notify_observers :from_pending_to_paid
    end
  end

  describe "#after_save" do
    context "when we change a projecte state to online" do
      let(:project){ create(:project, state: 'approved') }
      let(:user){ project.user }

      it "should set user has_online_project in mixpanel" do
        expect(people).to receive(:set).with(user.id.to_s, project_owner_properties.merge(has_online_project: true, published_projects: 1), user.current_sign_in_ip)
        project.push_to_online
      end
    end

    context "when we create a Reward" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated reward"), project.user.current_sign_in_ip)
        create(:reward, project: project)
      end
    end

  end

  describe "#after_create" do
    context "when we create a ProjectPost" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(
          project.user.id.to_s,
          "Project owner engaged with Catarse",
          project_owner_properties.merge({has_created_post: true, action: "Created post"}),
          project.user.current_sign_in_ip
        )
        create(:project_post, project: project)
      end
    end
  end

  describe "#after_update" do
    context "when we update a project's uploaded_image" do
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated uploaded_image"), project.user.current_sign_in_ip)
        project.update_attributes uploaded_image: File.open("#{Rails.root}/spec/fixtures/image.png")
      end
    end
    [:video_url, :about_html, :headline].each do |attribute|
      context "when we update a project's #{attribute}" do
        it "should send tracker a track call with the change" do
          expect(tracker).to receive(:track).with(project.user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated #{attribute}"), project.user.current_sign_in_ip)
          project.update_attributes attribute => 'https://www.youtube.com/watch?v=t2GsgdXfC5Q'
        end
      end
    end


    context "when we update a project owner profile" do
      let(:user){ project.user }
      it "should send tracker a track call with the change" do
        expect(tracker).to receive(:track).with(user.id.to_s, "Project owner engaged with Catarse", project_owner_properties.merge(action: "Updated profile"), project.user.current_sign_in_ip)
        expect(people).to receive(:set).with(user.id.to_s, project_owner_properties.merge(action: "Updated profile"), project.user.current_sign_in_ip)
        user.update_attributes about_html: 'test'
      end
    end
  end

end


