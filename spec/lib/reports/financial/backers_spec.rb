require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Reports::Financial::Backers do
  describe ".report" do
    before do
      @project = create(:project)
      user = create(:user, :cpf => '111.111.111-11')
      confirmed_backer = create(:backer, :value => (13.00),:project => @project, :user => user, :confirmed => true)
      not_confirmed_backer = create(:backer, :value => (199.00),:project => @project, :user => user, :confirmed => false)
    end

    subject{ Reports::Financial::Backers.report(@project.to_param) }

    it{ should_not =~ /R\$ 199/ }
    it{ should_not =~ /\,199/ }
    it{ should_not =~ /R\$ 13/ }
    it{ should =~ /13/ }
    it{ should =~ /111.111.111-11/ }
  end
end
