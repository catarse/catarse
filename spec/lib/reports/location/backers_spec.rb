require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  describe ".report" do
    before do
      @project = create(:project)
      user = create(:user, :address_city => 'Pedro Leopoldo', :address_state => 'MG', :address_street => 'test', :address_number => 12)
      user2 = create(:user, :address_city => 'Porto Alegre', :address_state => 'RS', :address_street => 'test', :address_number => 12)
      confirmed_backer = create(:backer, :value => (13.00),:project => @project, :user => user, :confirmed => true)
      not_confirmed_backer = create(:backer, :value => (199.00),:project => @project, :user => user2, :confirmed => false)
    end

    subject{ Reports::Location::Backers.report(@project.to_param) }

    it{ should_not =~ /Porto Alegre/ }
    it{ should_not =~ /RS/ }
    it{ should =~ /Pedro Leopoldo/ }
    it{ should =~ /MG/ }
  end
end
