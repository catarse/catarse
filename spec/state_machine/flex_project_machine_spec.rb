require 'rails_helper'

RSpec.describe FlexProjectMachine, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: 'draft') }
  let(:flexible_project) { create(:flexible_project, project: project, state: project_state) }
  let!(:project_account) { create(:project_account, project: project) }

  describe "state_machine" do
    subject { flexible_project.state_machine }

    before do
      allow(flexible_project).to receive(:notify_observers).and_call_original
    end

    context "should starts in draft" do
      it do
        expect(subject.current_state).to eq("draft")
      end
    end

    context "transitions" do
      shared_examples "valid project transaction flow" do |transition_to|
        before do
          expect(flexible_project).to receive(:notify_observers).
            with(:"from_#{project_state}_to_#{transition_to.to_s}").
            and_call_original

          subject.transition_to(transition_to, { to_state: transition_to })
        end

        it "should turn current_state to #{transition_to}" do
          expect(subject.current_state).to eq(transition_to.to_s)
        end

        it "should persist the current_status into project.state" do
          expect(flexible_project.state).to eq(transition_to.to_s)
        end

        it "should create an most recent transition to_locale" do
          expect(flexible_project.transitions.
            where(to_state: transition_to.to_s).count).to eq(1)
        end
      end

      FlexProjectMachine.states.each do |state| 
        shared_examples "valid #{state} project transaction" do
          it_should_behave_like "valid project transaction flow", state.to_sym
        end

        shared_examples "invalid #{state} project transaction" do
          it_should_behave_like "invalid project transaction flow", state.to_sym
        end
      end

      shared_examples "invalid project transaction flow" do |transition_to|
        before do
          subject.transition_to transition_to, {to_state: transition_to}
        end

        it "should not turn current_state to #{transition_to.to_s}" do
          expect(subject.current_state).not_to eq(transition_to.to_s)
        end

        it "should not turn project.state to #{transition_to.to_s}" do
          expect(flexible_project.reload.state).not_to eq(transition_to.to_s)
        end

        it "should not create an most recent transition to_locale" do
          expect(flexible_project.transitions.where(to_state: transition_to.to_s).count).to eq(0)
        end
      end

      context "rejected can go to draft, deleted only" do
        let(:project_state) { 'rejected' }

        it_should_behave_like "valid draft project transaction"
        it_should_behave_like "valid deleted project transaction"

        %i(online successful waiting_funds).each do |state|
          it "can't transition from rejected to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end
      end

      context "draft project can go to online" do
        %i(draft successful waiting_funds).each do |state|
          it "can't transition from draft to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end

        context "when is valid project" do 
          it_should_behave_like "valid online project transaction"
        end

        context "when is invalid project" do
          before do
            project.name = nil
            project.about_html = nil
          end

          context "online transition" do
            it_should_behave_like "invalid online project transaction"
          end
        end
      end

      context "online project can go to waiting_funds or successful" do
        let(:project_state) { 'online' }

        context "waiting_funds transition" do 
          context "when can go to waiting_funds" do
            context "project expired and have waiting payments" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(true)
                allow(flexible_project).to receive(:in_time_to_wait?).and_return(true)
              end

              it_should_behave_like "valid waiting_funds project transaction"
            end
          end

          context "when can't go to waiting_funds" do
            context "project expired but not have pending payments" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(true)
                allow(flexible_project).to receive(:in_time_to_wait?).and_return(false)
              end

              it_should_behave_like "invalid waiting_funds project transaction"
            end

            context "project not expired" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(false)
              end

              it_should_behave_like "invalid waiting_funds project transaction"
            end
          end
        end

        context "successful transition" do
          context "when can go to successful" do
            before do
              expect(flexible_project).to receive(:notify_observers).
                with(:sync_with_mailchimp).and_call_original
            end

            context "project expired and not have waiting payments" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(true)
                allow(flexible_project).to receive(:in_time_to_wait?).and_return(false)
              end

              it_should_behave_like "valid successful project transaction"
            end
          end

          context "when can't go to successful" do
            before do
              expect(flexible_project).not_to receive(:notify_observers).
                with(:sync_with_mailchimp).and_call_original
            end

            context "project expired but have pending payments" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(true)
                allow(flexible_project).to receive(:in_time_to_wait?).and_return(true)
              end

              it_should_behave_like "invalid successful project transaction"
            end

            context "project not expired" do
              before do
                allow(flexible_project).to receive(:expired?).and_return(false)
              end

              it_should_behave_like "invalid successful project transaction"
            end
          end
        end
      end

      context "waiting_funds project can go to successful" do
        let(:project_state) { 'waiting_funds' }

        before do
          allow(flexible_project).to receive(:expired?).and_return(true)
        end

        context "successful transition" do
          context "when can go to successful" do
            context "project not have waiting payments" do
              before do
                expect(flexible_project).to receive(:notify_observers).
                  with(:sync_with_mailchimp).and_call_original

                allow(flexible_project).to receive(:in_time_to_wait?).
                  and_return(false)
              end

              it_should_behave_like "valid successful project transaction"
            end
          end

          context "when can't go to successful" do
            context "project have pending payments" do
              before do
                expect(flexible_project).not_to receive(:notify_observers).
                  with(:sync_with_mailchimp).and_call_original

                allow(flexible_project).to receive(:in_time_to_wait?).
                  and_return(true)
              end

              it_should_behave_like "invalid successful project transaction"
            end
          end
        end
      end
    end

    context "instance methods" do
      context "#push_to_draft" do
        before do
          expect(subject).to receive(:transition_to).
            with(:draft, {to_state: "draft"}).and_call_original
        end

        it { subject.push_to_draft } 
      end

      context "#push_to_trash" do
        before do
          expect(subject).to receive(:transition_to).
            with(:deleted, {to_state: "deleted"}).and_call_original
        end

        it { subject.push_to_trash }
      end

      context "#reject" do
        before do
          expect(subject).to receive(:transition_to).
            with(:rejected, {to_state: "rejected"}).and_call_original
        end

        it { subject.reject }
      end

      context "#push_to_online" do
        before do 
          expect(subject).to receive(:transition_to).
            with(:online, {to_state: 'online'}).and_call_original
        end 

        it { subject.push_to_online }
      end

      context "#finish" do
        let(:project_state) { 'online' }

        before do
          allow(flexible_project).to receive(:expired?).
            and_return(true)
        end

        context "when can't go to successful" do
          before do
            allow(flexible_project).to receive(:in_time_to_wait?).
              and_return(true)

            expect(subject).to receive(:transition_to).
              with(:waiting_funds, {to_state: 'waiting_funds'}).and_return(true)

            expect(subject).not_to receive(:transition_to).
              with(:successful, {to_state: 'successful'})
          end

          it { subject.finish }
        end

        context "when can go to successful" do
          before do
            allow(flexible_project).to receive(:in_time_to_wait?).
              and_return(false)

            expect(subject).to receive(:transition_to).
              with(:waiting_funds, {to_state: 'waiting_funds'}).and_return(false)

            expect(subject).to receive(:transition_to).
              with(:successful, {to_state: 'successful'}).and_return(true)
          end

          it { subject.finish }
        end
      end
    end

  end
end
