require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  it "show only the confirmed backers" do
    @project = create(:project)
    user = create(:user, :address_city => 'Pedro Leopoldo', :address_state => 'MG')
    user2 = create(:user, :address_city => 'Porto Alegre', :address_state => 'RS')

    confirmed_backer = create(:backer, :value => (13.00),:project => @project, :user => user, :confirmed => true)
    not_confirmed_backer = create(:backer, :value => (199.00),:project => @project, :user => user2, :confirmed => false)

    report = Reports::Location::Backers.report(@project.to_param)
    report.should_not =~ /Porto Alegre/
    report.should_not =~ /RS/
    report.should =~ /Pedro Leopoldo/
    report.should =~ /MG/
  end
end