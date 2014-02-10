require "spec_helper"

describe ContributionPolicy do
  subject{ ContributionPolicy }

  let(:project){ create(:project) }
  let(:contribution){ create(:contribution) }
  let(:user){ contribution.user }

  shared_examples_for "update permissions" do
    it "should deny access if user is nil" do
      should_not permit(nil, contribution)
    end

    it "should deny access if user is not updating his contribution" do
      should_not permit(User.new, contribution)
    end

    it "should permit access if user is contribution owner" do
      should permit(user, contribution)
    end

    it "should permit access if user is admin" do
      admin = build(:user, admin: true)
      should permit(admin, contribution)
    end
  end

  shared_examples_for "create permissions" do
    it_should_behave_like "update permissions" 

    ['draft', 'deleted', 'rejected', 'successful', 'failed', 'waiting_funds', 'in_analysis'].each do |state|
      it "should deny access if project is #{state}" do
        contribution.project.update_attributes state: state
        should_not permit(user, contribution)
      end
    end
  end

  permissions(:new?){ it_should_behave_like "create permissions" }

  permissions(:create?){ it_should_behave_like "create permissions" }

  permissions(:show?){ it_should_behave_like "update permissions" }

  permissions(:update?){ it_should_behave_like "update permissions" }

  permissions(:edit?){ it_should_behave_like "update permissions" }

  permissions(:credits_checkout?){ it_should_behave_like "update permissions" }

  permissions(:request_refund?){ it_should_behave_like "update permissions" }

  describe 'Scope' do
    describe ".resolve" do
      let(:user) { create(:user, admin: false) }
      before do
        create(:contribution, state: 'waiting_confirmation', project: project)
        create(:contribution, anonymous: true, state: 'confirmed', project: project)
        @contribution = create(:contribution, anonymous: false, state: 'confirmed', project: project)
      end

      subject { ContributionPolicy::Scope.new(user, project.contributions).resolve }

      context "when user is admin" do
        let(:user) { create(:user, admin: true) }

        it { should have(3).itens }
      end

      context "when user is not an admin" do
        it { should eq [@contribution] }
      end
    end
  end
end
