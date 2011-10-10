require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  context "project with some backers" do
    before do
      @project = create(:project)
      4.times do |n|
        user = create(:user)
        backer = create(:backer, :value => (10.00+n),:project => @project, :user => user)
        create(:payment_detail, :backer => backer)
      end
    end

    it 'should have the backers information' do
      report = Reports::Financial::Backers.report(@project.to_param)
      report.should_not =~ /R\$ 10/
      report.should =~ /10/
      report.should_not =~ /R\$ 11/
      report.should =~ /11/
      report.should_not =~ /R\$ 12/
      report.should =~ /12/
      report.should =~ /person\d+@example.com/
      report.should_not =~ /R\$ 19,37/
      report.should =~ /19.37/
      report.should =~ /Lorem/
      report.should =~ /BoletoBancario/
    end
  end
end