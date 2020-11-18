require 'rails_helper'

RSpec.describe CatarseScripts::ScriptExecutorJob, type: :job do
  describe '#perform' do
    let(:script) { create(:script, status: :pending) }
    let(:code) do
      <<-RUBY
        class <ScriptClassName>
          def call(worker = nil)
            CatarseScripts::Script.find('#{script.id}').update(title: 'New Title')
          end
        end
      RUBY
    end

    before do
      allow(CatarseScripts::Script).to receive(:find).with(script.id).and_return(script)
    end

    it 'updates script status to done' do
      described_class.perform_now(script.id)

      expect(script).to be_done
    end

    it 'executes script code' do
      script.update(code: code)
      described_class.perform_now(script.id)
      script.reload
      expect(script.title).to eq 'New Title'
    end

    context 'when an error happens' do
      let(:code) do
        <<-RUBY
          class <ScriptClassName>
            def call(worker = nil)
              raise 'Error'
            end
          end
        RUBY
      end

      it 'updates script status to done' do
        script.update(code: code)
        described_class.perform_now(script.id)

        expect(script.reload).to be_with_error
      end
    end
  end
end
