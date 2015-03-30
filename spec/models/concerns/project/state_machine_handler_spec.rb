require 'rails_helper'

RSpec.describe Project::StateMachineHandler, type: :model do
  let(:user){ create(:user, cpf: '99999999999', phone_number: '99999999', moip_login: 'foobar', uploaded_image: File.open("#{Rails.root}/spec/support/testimg.png"), name: 'name' ) }

  describe "state machine" do
    let(:project) do 
     project = create(:project, state: 'draft', online_date: nil, user: user) 
     create(:reward, project: project)
     project.update_attribute :state, project_state
     project
    end

    let(:project_state){ 'draft' }

    describe "#send_to_analysis" do
      context "when project has no goal" do
        subject { project.send_to_analysis }
        let(:project) { create(:project, goal: nil, state: 'draft') }

        it "should raise an error" do
          subject
          expect(project.errors).to_not be_nil
        end

      end

      context "when project user has no name" do
        subject { project.send_to_analysis }
        let(:user) { create(:user, name: nil)}
        let(:project) { create(:project, user: user, state: 'draft') }

        it "should raise an error" do
          subject
          expect(project.errors).to_not be_nil
        end

      end

      context "when project is draft" do
        let(:project_state){ 'draft' }

        subject { project.send_to_analysis }
        before do
          expect(project).to receive(:notify_observers).with(:from_draft_to_in_analysis).and_call_original
        end

        it { is_expected.to eq(true) }

        it "should store sent_to_analysis_at" do
          subject
          expect(project.sent_to_analysis_at).to_not be_nil
        end
      end
    end

    describe '#push_to_draft' do
      context "when project is rejected" do
        let(:project_state){ 'rejected' }
        subject{ project.push_to_draft }
        it{ should eq(true) }
        it "should mark sent_to_draft_at" do
          subject
          expect(project.sent_to_draft_at).to_not be_nil
        end
      end
    end

    describe '#reject' do
      context "when project is in_analysis" do
        let(:project_state){ 'in_analysis' }
        before do
          expect(project).to receive(:notify_observers).with(:from_in_analysis_to_rejected)
        end
        subject{ project.reject }
        it{ should eq(true) }
        it "should mark rejected_at" do
          subject
          expect(project.rejected_at).to_not be_nil
        end
      end
    end

    describe '#push_to_trash' do
      context "when project is draft" do
        let(:project_state){ 'draft' }

        subject{ project.push_to_trash }

        it{ should eq true }
        it "should change permalink" do
          subject
          expect(project.permalink).to eq "deleted_project_#{project.id}"
        end
      end
    end

    describe '#approve' do
      let(:project_state){ 'in_analysis' }

      subject{ project.approve }

      context "when project has no video" do
        before do
          project.update_attribute :video_url, nil
        end

        it "should raise an error" do
          subject
          expect(project.errors).to_not be_nil
        end

      end

      context "when project is in_analysis" do
        before do
          expect(project).to receive(:notify_observers).with(:from_in_analysis_to_approved).and_call_original
        end
        it{ is_expected.to eq true }
      end
    end

    describe '#push_to_online' do
      let(:project_state){ 'approved' }

      subject{ project.push_to_online }

      context "when project user has no email" do
        before do
          project.user.update_attribute :email, nil
        end

        it "should raise an error" do
          subject
          expect(project.errors).to_not be_nil
        end

      end

      context "when project is approved" do
        before do
          expect(project).to receive(:notify_observers).with(:from_approved_to_online).and_call_original
        end
        it{ is_expected.to eq true }
        it 'should persist the online_date' do
          subject
          expect(project.online_date).to_not be_nil
          expect(project.audited_user_name).to_not be_nil
          expect(project.audited_user_cpf).to_not be_nil
          expect(project.audited_user_moip_login).to_not be_nil
          expect(project.audited_user_phone_number).to_not be_nil
        end
      end
    end

    describe '#finish' do
      let(:project) { create(:project, goal: 30_000, online_days: 1, online_date: Time.now - 2.days, state: project_state) }
      subject { project.finish }
      let(:project_state){ 'online' }

      context 'when project is not approved' do
        let(:project_state){ 'draft' }
        it{ is_expected.to eq false }
      end

      context 'when project is expired and the sum of the pending contributions and confirmed contributions dont reached the goal' do
        before do
          create(:confirmed_contribution, value: 100, project: project, created_at: 2.days.ago)
          create(:pending_contribution, value: 100, project: project)
        end

        it{ is_expected.to eq true }

        it "should go to waiting_funds" do
          subject
          expect(project).to be_waiting_funds
        end
      end

      context 'when project is expired and have recent contributions without confirmation' do
        before do
          create(:pending_contribution, value: 30_000, project: project)
        end

        it{ is_expected.to eq true }

        it "should go to waiting_funds" do
          subject
          expect(project).to be_waiting_funds
        end
      end

      context 'when project already hit the goal and passed the waiting_funds time' do
        let(:project_state){ 'waiting_funds' }
        before do
          allow(project).to receive(:reached_goal?).and_return(true)
        end

        it{ is_expected.to eq true }

        it "should go to successful" do
          subject
          expect(project).to be_successful
        end
      end

      context 'when project already hit the goal and still is in the waiting_funds time' do
        let(:project_state){ 'waiting_funds' }
        before do
          allow(project).to receive(:reached_goal?).and_return(true)
          allow(project).to receive(:in_time_to_wait?).and_return(true)
        end

        it{ is_expected.to eq true }

        it "should go to waiting_funds" do
          subject
          expect(project).to be_waiting_funds
        end
      end

      context 'when project not hit the goal' do
        it{ is_expected.to eq true }
        it "should go to failed" do
          subject
          expect(project).to be_failed
        end
      end
    end
  end
end
