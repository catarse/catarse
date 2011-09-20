require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  context "project with some backers" do
    before do
      @project = create(:project)
      4.times do |n|
        user = create(:user)
        create(:backer, :value => (10.00+n),:project => @project, :user => user)
      end
    end

    it 'should have the backers information' do
      report = Reports::Financial::Backers.report(@project.to_param)
      report.should =~ /R\$ 10/
      report.should =~ /R\$ 11/
      report.should =~ /R\$ 12/
      report.should =~ /person[\d]\@example\.com/
    end
  end
end