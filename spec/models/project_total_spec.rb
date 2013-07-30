require 'spec_helper'

describe ProjectTotal do
  before do
    @project_id = FactoryGirl.create(:backer, value: 10.0, payment_service_fee: 1, state: 'pending').project_id
    FactoryGirl.create(:backer, value: 10.0, payment_service_fee: 1, state: 'confirmed', project_id: @project_id)
    FactoryGirl.create(:backer, value: 10.0, payment_service_fee: 1, state: 'waiting_confirmation', project_id: @project_id)
    FactoryGirl.create(:backer, value: 10.0, payment_service_fee: 1, state: 'refunded', project_id: @project_id)
    FactoryGirl.create(:backer, value: 10.0, payment_service_fee: 1, state: 'requested_refund', project_id: @project_id)
  end

  describe "#pledged" do
    subject{ ProjectTotal.where(project_id: @project_id).first.pledged }
    it{ should == 30 }
  end

  describe "#total_backers" do
    subject{ ProjectTotal.where(project_id: @project_id).first.total_backers }
    it{ should == 3 }
  end

  describe "#total_payment_service_fee" do
    subject { ProjectTotal.where(project_id: @project_id).first.total_payment_service_fee }
    it { should == 3 }
  end
end
