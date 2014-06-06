require 'spec_helper'

describe ProjectSchedulerWorker do
  let(:project) { build(:project, state: 'in_analysis', online_date: 10.days.from_now) }

  before do
    Sidekiq::Testing.inline!

    Project.any_instance.should_receive(:approve)
  end

  it("should satisfy expectations") { project.save }
end
