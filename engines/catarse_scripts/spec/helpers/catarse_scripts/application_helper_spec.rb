require 'rails_helper'

RSpec.describe CatarseScripts::ApplicationHelper, type: :helper do
  describe '#script_status_class' do
    context 'when script status is pending' do
      it 'returns orange color' do
        expect(helper.script_status_class('pending')).to eq 'bg-orange-300'
      end
    end

    context 'when script status is running' do
      it 'returns blue color' do
        expect(helper.script_status_class('running')).to eq 'bg-blue-400'
      end
    end

    context 'when script status is done' do
      it 'returns green color' do
        expect(helper.script_status_class('done')).to eq 'bg-green-500'
      end
    end

    context 'when script status is with_error' do
      it 'returns red color' do
        expect(helper.script_status_class('with_error')).to eq 'bg-red-500'
      end
    end
  end
end
