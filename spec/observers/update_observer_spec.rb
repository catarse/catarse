require 'spec_helper'

describe UpdateObserver do
  describe 'after_create' do
    context "call notify update worker" do
      before do
        @project = Factory(:project)
      end

      it "should send to queue" do
        update = Update.create!(:user => @project.user, :project => @project, :comment => "this is a comment")
        NotifyUpdateWorker.jobs.size.should == 1
      end
    end
  end
end
