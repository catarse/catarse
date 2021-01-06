require 'rails_helper'

RSpec.describe ScriptPolicy, type: :policy do
  subject(:policy) { described_class.new(user: user) }

  let(:user) { double }

  describe '#can_read?' do
    context 'when user is dev or executor' do
      before do
        allow(policy).to receive(:done_by_dev_or_executor?).and_return(true)
      end

      it 'returns true' do
        expect(policy.can_read?).to be_truthy
      end
    end

    context 'when user isn`t dev nor executor' do
      before do
        allow(policy).to receive(:done_by_dev_or_executor?).and_return(false)
      end

      it 'returns false' do
        expect(policy.can_read?).to be_falsey
      end
    end
  end

  describe '#can_create?' do
    context 'when user is dev or executor' do
      before do
        allow(policy).to receive(:done_by_dev_or_executor?).and_return(true)
      end

      it 'returns true' do
        expect(policy.can_create?).to be_truthy
      end
    end

    context 'when user isn`t dev nor executor' do
      before do
        allow(policy).to receive(:done_by_dev_or_executor?).and_return(false)
      end

      it 'returns false' do
        expect(policy.can_create?).to be_falsey
      end
    end
  end

  describe '#can_update?' do
    let(:script) { CatarseScripts::Script.new }

    context 'when script isn`t executed' do
      before { allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(true) }

      context 'when user is executor or script creator' do
        before { allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(true) }

        it 'returns true' do
          expect(policy.can_update?(script)).to be_truthy
        end
      end

      context 'when user isn`t executor nor script creator' do
        before { allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(false) }

        it 'returns false' do
          expect(policy.can_update?(script)).to be_falsey
        end
      end
    end

    context 'when script is executed' do
      before do
        allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(false)
        allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(true)
      end

      it 'returns false' do
        expect(policy.can_update?(script)).to be_falsey
      end
    end
  end

  describe '#can_destroy?' do
    let(:script) { CatarseScripts::Script.new }

    context 'when script isn`t executed' do
      before { allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(true) }

      context 'when user is executor or script creator' do
        before { allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(true) }

        it 'returns true' do
          expect(policy.can_destroy?(script)).to be_truthy
        end
      end

      context 'when user isn`t executor nor script creator' do
        before { allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(false) }

        it 'returns false' do
          expect(policy.can_destroy?(script)).to be_falsey
        end
      end
    end

    context 'when script is executed' do
      before do
        allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(false)
        allow(policy).to receive(:done_by_executor_or_script_creator?).with(script).and_return(true)
      end

      it 'returns false' do
        expect(policy.can_destroy?(script)).to be_falsey
      end
    end
  end

  describe '#can_execute?' do
    let(:script) { CatarseScripts::Script.new }

    context 'when script isn`t executed' do
      before { allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(true) }

      context 'when user is executor' do
        before { allow(policy).to receive(:done_by_executor?).and_return(true) }

        it 'returns true' do
          expect(policy.can_execute?(script)).to be_truthy
        end
      end

      context 'when user isn`t executor' do
        before { allow(policy).to receive(:done_by_executor?).and_return(false) }

        it 'returns false' do
          expect(policy.can_execute?(script)).to be_falsey
        end
      end
    end

    context 'when script is executed' do
      before do
        allow(policy).to receive(:is_script_not_excuted?).with(script).and_return(false)
        allow(policy).to receive(:done_by_executor?).and_return(true)
      end

      it 'returns false' do
        expect(policy.can_execute?(script)).to be_falsey
      end
    end
  end

  describe '#is_script_not_excuted?' do
    let(:script) { CatarseScripts::Script.new(status: status) }

    context 'when script is pending' do
      let(:status) { :pending }

      it 'returns true' do
        expect(policy.is_script_not_excuted?(script)).to be_truthy
      end
    end

    context 'when script is with_error' do
      let(:status) { :with_error }

      it 'returns true' do
        expect(policy.is_script_not_excuted?(script)).to be_truthy
      end
    end

    context 'when script isn`t with_error nor pending' do
      let(:status) { (CatarseScripts::Script.statuses.keys - ['with_error', 'pending']).sample }

      it 'returns false' do
        expect(policy.is_script_not_excuted?(script)).to be_falsey
      end
    end
  end

  describe '#done_by_executor_or_script_creator?' do
    let(:script) { CatarseScripts::Script.new(creator_id: creator_id) }
    let(:user) { double(id: 123) }

    context 'when user is executor' do
      let(:creator_id) { 321 }

      before do
        allow(policy).to receive(:done_by_executor?).and_return(true)
      end

      it 'returns true' do
        expect(policy.done_by_executor_or_script_creator?(script)).to be_truthy
      end
    end

    context 'when user is script creator' do
      let(:creator_id) { 123 }

      before do
        allow(policy).to receive(:done_by_executor?).and_return(false)
      end

      it 'returns true' do
        expect(policy.done_by_executor_or_script_creator?(script)).to be_truthy
      end
    end

    context 'when user isn`t executor nor script creator' do
      let(:creator_id) { 321 }

      before do
        allow(policy).to receive(:done_by_executor?).and_return(false)
      end

      it 'returns false' do
        expect(policy.done_by_executor_or_script_creator?(script)).to be_falsey
      end
    end
  end

  describe '#done_by_dev_or_executor?' do
    context 'when user is executor' do
      before do
        allow(policy).to receive(:done_by_executor?).and_return(true)
        allow(policy).to receive(:done_by_dev?).and_return(false)
      end

      it 'returns true' do
        expect(policy.done_by_dev_or_executor?).to be_truthy
      end
    end

    context 'when user is dev' do
      before do
        allow(policy).to receive(:done_by_executor?).and_return(false)
        allow(policy).to receive(:done_by_dev?).and_return(true)
      end

      it 'returns true' do
        expect(policy.done_by_dev_or_executor?).to be_truthy
      end
    end

    context 'when user isn`t executor nor dev' do
      before do
        allow(policy).to receive(:done_by_executor?).and_return(false)
        allow(policy).to receive(:done_by_dev?).and_return(false)
      end

      it 'returns false' do
        expect(policy.done_by_dev_or_executor?).to be_falsey
      end
    end
  end

  describe '#done_by_executor?' do
    context 'when user is admin' do
      let(:user) { double(admin?: true, admin_roles: double) }

      context 'when user has script_executor admin role' do
        let(:admin_roles) { ['script_executor'] }

        before do
          allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
        end

        it 'returns true' do
          expect(policy.done_by_executor?).to be_truthy
        end
      end

      context 'when user hasn`t script_executor admin role' do
        let(:user) { double(admin?: true, admin_roles: double) }
        let(:admin_roles) { ['script_dev'] }

        before do
          allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
        end

        it 'returns false' do
          expect(policy.done_by_executor?).to be_falsey
        end
      end
    end

    context 'when user isn`t admin' do
      let(:user) { double(admin?: false, admin_roles: double) }
      let(:admin_roles) { ['script_dev', 'script_executor'] }

      before do
        allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
      end

      it 'returns false' do
        expect(policy.done_by_executor?).to be_falsey
      end
    end
  end

  describe '#done_by_dev?' do
    context 'when user is admin' do
      let(:user) { double(admin?: true, admin_roles: double) }

      context 'when user has script_dev admin role' do
        let(:admin_roles) { ['script_dev'] }

        before do
          allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
        end

        it 'returns true' do
          expect(policy.done_by_dev?).to be_truthy
        end
      end

      context 'when user hasn`t script_dev admin role' do
        let(:user) { double(admin?: true, admin_roles: double) }
        let(:admin_roles) { ['script_executor'] }

        before do
          allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
        end

        it 'returns false' do
          expect(policy.done_by_dev?).to be_falsey
        end
      end
    end

    context 'when user isn`t admin' do
      let(:user) { double(admin?: false, admin_roles: double) }
      let(:admin_roles) { ['script_dev', 'script_executor'] }

      before do
        allow(user.admin_roles).to receive(:pluck).with(:role_label).and_return(admin_roles)
      end

      it 'returns false' do
        expect(policy.done_by_dev?).to be_falsey
      end
    end
  end
end
