require 'rails_helper'

RSpec.describe ProjectSchedulerWorker do
  let(:project) { build(:project, state: 'approved', online_date: 10.days.from_now) }

  before do
    Sidekiq::Testing.inline!

    expect_any_instance_of(Project).to receive(:push_to_online)
  end

  it("should satisfy expectations") { project.save(validate: false) }
end
