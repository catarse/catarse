require 'rails_helper'

RSpec.describe ProjectSchedulerWorker do
  let(:project) { build(:project, state: 'in_analysis', online_date: 10.days.from_now) }

  before do
    Sidekiq::Testing.inline!

    expect_any_instance_of(Project).to receive(:approve)
  end

  it("should satisfy expectations") { project.save }
end
