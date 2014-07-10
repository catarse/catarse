require 'spec_helper'

describe ProjectPostObserver do
  describe 'after_create' do
    context "notify contributions" do
      let(:project) { create(:project) }
      let(:project_post) { build(:project_post) }

      it "should satisfy expectations" do
        project_post.should_receive(:notify_contributors)
        project_post.save
      end
    end
  end
end
