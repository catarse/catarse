require 'spec_helper'

describe ProjectPostObserver do
  describe 'after_create' do
    context "notify contributions" do
      let(:project) { create(:project) }
      let(:project_post) { create(:project_post) }

      it "should satisfy expectations" do
        ProjectPostWorker.should_receive(:perform_async).with(project_post.id)
        project_post.save
      end
    end
  end
end
