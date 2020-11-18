require 'rails_helper'

RSpec.describe CatarseScripts::Script, type: :model do
  describe 'Association' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:executor).class_name('User').optional(true) }
  end

  describe 'Enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, running: 1, done: 2, with_error: 3) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:creator_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:code) }

    it { is_expected.to validate_length_of(:title).is_at_most(128) }
    it { is_expected.to validate_length_of(:description).is_at_most(512) }
    it { is_expected.to validate_length_of(:code).is_at_most(32768) }
    it { is_expected.to validate_length_of(:ticket_url).is_at_most(512) }
  end

  describe 'Callbacks' do
    describe '#before_validation' do
      context 'when script is being created' do
        let(:script) { described_class.new(class_name: nil) }

        before { travel_to Time.local(1994) }
        after { travel_back }

        it 'generates class name' do
          script.validate
          expected_class_name = "::TempScript#{Time.zone.now.strftime('%Y%m%d%H%M%S%L')}"
          expect(script.class_name).to eq expected_class_name
        end
      end

      context 'when script is being updated' do
        let(:script) { create(:script) }

        it 'doesn`t generate class name' do
          expect(script).not_to receive(:generate_class_name)

          script.validate
        end
      end
    end

    describe '#before_save' do
      let(:script) { build(:script, creator: create(:user), code: 'class <ScriptClassName> end') }

      it 'replaces code class name' do
        script.save
        expect(script.code).to eq "class #{script.class_name} end"
      end
    end


    describe '#before_update' do
      context 'when script status is being updated' do
        let(:script) { create(:script, status: :pending) }

        it 'keeps status change' do
          script.update(status: :with_error)
          expect(script.status).to eq "with_error"
        end
      end

      context 'when script status is not being updated' do
        context 'when script status is with_error' do
          let(:script) { create(:script, status: :with_error) }

          it 'udpates script status to pending' do
            script.update(description: 'teste')
            expect(script.status).to eq "pending"
          end
        end

        context 'when script status isn`t with_error' do
          let(:status) { (CatarseScripts::Script.statuses.keys - ['with_error']).sample }
          let(:script) { create(:script, status: status) }

          it 'doesn`t update script status' do
            script.update(description: 'teste')
            expect(script.status).to eq status
          end
        end
      end
    end
  end
end
