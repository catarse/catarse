require 'spec_helper'

describe BackerTotal do
  before do
    @project_id = Factory(:backer, :value => 10.0, :confirmed => false).project_id
    Factory(:backer, :value => 10.0, :confirmed => true, :project_id => @project_id)
  end
end
