require 'spec_helper'

describe Project::StateMachineHandler do
  let(:user){ create(:user, full_name: 'Lorem Ipsum', cpf: '99999999999', phone_number: '99999999', moip_login: 'foobar') }

  describe "state machine" do
    let(:project) { create(:project, state: 'draft', online_date: nil, user: user) }

    describe "#send_to_analysis" do
      subject { project.in_analysis? }
      before do
        project.should_receive(:notify_observers).with(:from_draft_to_in_analysis).and_call_original
        project.send_to_analysis
      end

      it { should be_true }

      it "should store sent_to_analysis_at" do
        expect(project.sent_to_analysis_at).to_not be_nil
      end
    end

    describe '#draft?' do
      subject { project.draft? }
      context "when project is new" do
        it { should be_true }
      end
    end

    describe '.push_to_draft' do
      subject do
        project.reject
        project.push_to_draft
        project
      end
      its(:draft?){ should be_true }
    end

    describe '#rejected?' do
      subject { project.rejected? }
      before do
        project.send_to_analysis
        project.reject
      end
      context 'when project is not accepted' do
        it { should be_true }
      end
    end

    describe '#reject' do
      before { project.update_attributes state: 'in_analysis' }
      subject do
        project.should_receive(:notify_observers).with(:from_in_analysis_to_rejected)
        project.reject
        project
      end
      its(:rejected?){ should be_true }
    end

    describe '#push_to_trash' do
      let(:project) { create(:project, permalink: 'my_project', state: 'draft') }

      subject do
        project.push_to_trash
        project
      end

      its(:deleted?) { should be_true }
      its(:permalink) { should == "deleted_project_#{project.id}" }
    end

    describe '#approve' do
      before { project.send_to_analysis }

      subject do
        project.should_receive(:notify_observers).with(:from_in_analysis_to_online)
        project.approve
        project
      end

      its(:online?){ should be_true }
      it('should call after transition method to notify the project owner'){ subject }
      it 'should persist the online_date' do
        project.approve
        expect(project.online_date).to_not be_nil
        expect(project.audited_user_name).to_not be_nil
        expect(project.audited_user_cpf).to_not be_nil
        expect(project.audited_user_moip_login).to_not be_nil
        expect(project.audited_user_phone_number).to_not be_nil
      end
    end

    describe '#online?' do
      before do
        project.send_to_analysis
        project.approve
      end
      subject { project.online? }
      it { should be_true }
    end

    describe '#finish' do
      let(:main_project) { create(:project, goal: 30_000, online_days: -1) }
      subject { main_project }

      context 'when project is not approved' do
        before do
          main_project.update_attributes state: 'draft'
        end
        its(:finish) { should be_false }
      end

      context 'when project is expired and the sum of the pending contributions and confirmed contributions dont reached the goal' do
        before do
          create(:contribution, value: 100, project: subject, created_at: 2.days.ago)
          subject.finish
        end

        its(:failed?) { should be_true }
      end

      context 'when project is expired and have recent contributions without confirmation' do
        before do
          create(:contribution, value: 30_000, project: subject, state: 'waiting_confirmation')
          subject.finish
        end

        its(:waiting_funds?) { should be_true }
      end

      context 'when project already hit the goal and passed the waiting_funds time' do
        before do
          main_project.update_attributes state: 'waiting_funds'
          subject.stub(:pending_contributions_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          subject.online_date = 2.weeks.ago
          subject.online_days = 0
          subject.finish
        end
        its(:successful?) { should be_true }
      end

      context 'when project already hit the goal and still is in the waiting_funds time' do
        before do
          subject.stub(:pending_contributions_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          create(:contribution, project: main_project, user: user, value: 20, state: 'waiting_confirmation')
          main_project.update_attributes state: 'waiting_funds'
          subject.finish
        end
        its(:successful?) { should be_false }
      end

      context 'when project not hit the goal' do
        let(:user) { create(:user) }
        let(:contribution) { create(:contribution, project: main_project, user: user, value: 20, payment_token: 'ABC') }

        before do
          contribution
          subject.online_date = 2.weeks.ago
          subject.online_days = 0
          subject.finish
        end

        its(:failed?) { should be_true }

        it "should generate credits for users" do
          contribution.confirm!
          user.reload
          user.credits.should == 20
        end
      end
    end
  end
end
