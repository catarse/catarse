# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectPostObserver do
  describe 'after_create' do
    context 'notify contributions' do
      let(:project) { create(:project) }
      let(:project_post) { build(:project_post, project_id: project.id) }

      before do
        allow(project_post).to receive(:id).and_return(42)
      end

      it 'should satisfy expectations' do
        expect(ProjectPostWorker).to receive(:perform_async).with(project_post.id)
        project_post.save
      end
    end
  end
end
