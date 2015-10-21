require 'rails_helper'

RSpec.describe FlexibleProjectMachine, type: :model do
  let(:project_state) { 'draft' }
  let(:project) { create(:project, state: project_state) }
  let!(:project_account) { create(:project_account, project: project) }

  describe "state_machine" do
    subject { project.state_machine }

    context "should starts in draft" do
      it do
        expect(subject.current_state).to eq("draft")
      end
    end

    context "transitions" do

      shared_examples "valid project transaction flow" do |transition_to|
        before do
          subject.transition_to(transition_to)
        end

        it "should turn current_state to in_analysis" do
          expect(subject.current_state).to eq(transition_to.to_s)
        end

        it "should persist the current_status into project.state" do
          expect(project.state).to eq(transition_to.to_s)
        end

        it "should create an most recent transition to_locale" do
          expect(project.project_transitions.where(to_state: transition_to.to_s).count).to eq(1)
        end
      end

      FlexibleProjectMachine.states.each do |state| 
        shared_examples "valid #{state} project transaction" do
          it_should_behave_like "valid project transaction flow", state.to_sym
        end

        shared_examples "invalid #{state} project transaction" do
          it_should_behave_like "invalid project transaction flow", state.to_sym
        end
      end

      shared_examples "invalid project transaction flow" do |transition_to|
        before do
          subject.transition_to transition_to
        end

        it "should have errors on project" do
          expect(project.errors).not_to be_empty
        end

        it "should not turn current_state to #{transition_to.to_s}" do
          expect(subject.current_state).not_to eq(transition_to.to_s)
        end

        it "should not turn project.state to #{transition_to.to_s}" do
          expect(project.reload.state).not_to eq(transition_to.to_s)
        end

        it "should not create an most recent transition to_locale" do
          expect(project.project_transitions.where(to_state: transition_to.to_s).count).to eq(0)
        end
      end

      context "draft can go to in_analysis, rejected and deleted only" do
        %i(draft online approved successful waiting_funds).each do |state|
          it "can't transition from draft to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end

        context "in_analysis transaction" do 
          context "when is a valid project" do
            it_should_behave_like "valid rejected project transaction"
            it_should_behave_like "valid deleted project transaction"
            it_should_behave_like "valid in_analysis project transaction"
          end

          context "when is a invalid project" do
            before do
              project.name = nil
              subject.transition_to :in_analysis
            end

            it_should_behave_like "invalid in_analysis project transaction"
          end
        end

      end

      context "rejected can go to draft, deleted only" do
        let(:project_state) { 'rejected' }

        it_should_behave_like "valid draft project transaction"
        it_should_behave_like "valid deleted project transaction"

        %i(online approved in_analysis successful waiting_funds).each do |state|
          it "can't transition from draft to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end
      end

      context "in_analysis project can go to approved, draft, rejected, deleted" do
        let(:project_state) { 'in_analysis' }

        %i(successful waiting_funds in_analysis).each do |state|
          it "can't transition from in_analysis to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end

        context "when is valid project" do 
          it_should_behave_like "valid approved project transaction"
          it_should_behave_like "valid draft project transaction"
          it_should_behave_like "valid rejected project transaction"
          it_should_behave_like "valid deleted project transaction"
        end

        context "when is invalid project" do
          before do
            project.name = nil
          end

          context "approved transition" do
            it_should_behave_like "invalid approved project transaction"
          end
        end
      end

      context "approved project can go to online, in_analysis" do
        let(:project_state) { 'approved' }

        %i(draft deleted successful waiting_funds).each do |state|
          it "can't transition from approved to #{state}" do
            expect(subject.transition_to(state)).to eq(false)
          end
        end

        context "when is valid project" do 
          it_should_behave_like "valid online project transaction"
          it_should_behave_like "valid in_analysis project transaction"
        end

        context "when is invalid project" do
          before do
            project.name = nil
          end

          context "online transition" do
            it_should_behave_like "invalid online project transaction"
          end
        end
      end

      context "online project can go to waiting_funds or successful" do
        
      end

    end
  end
end
