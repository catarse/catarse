require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  context "project with some backers" do
    before do
      @project = create(:project)
      4.times do |n|
        user = create(:user)
        create(:backer, :project => @project, :user => user)
      end
    end

    it 'should have all backers' do
      report = Reports::Financial::Backers.report(@project.to_param)
      report.should have(4).itens
    end
  end
end