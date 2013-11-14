require 'spec_helper'

describe CampaignFinisher do
  let(:project_to_finish) { create(:project, state: 'waiting_funds') }
  let(:online_project) { create(:project, state: 'online') }

  subject { CampaignFinisher.new() }

  before do
    Project.stub(:to_finish).and_return([project_to_finish])
  end

  describe '#start!' do
    before do
      project_to_finish.should_receive(:finish).at_least(1)
      online_project.should_receive(:finish).never
    end

    it("should satify expectations") { subject.start! }
  end
end
