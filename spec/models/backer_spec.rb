require 'spec_helper'

describe Backer do
  let(:user){ create(:user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:unfinished_project_backer){ create(:backer, state: 'confirmed', user: user, project: unfinished_project) }
  let(:sucessful_project_backer){ create(:backer, state: 'confirmed', user: user, project: successful_project) }
  let(:not_confirmed_backer){ create(:backer, user: user, project: unfinished_project) }
  let(:valid_refund){ create(:backer, state: 'confirmed', user: user, project: failed_project) }


  describe "Associations" do
    it { should have_many(:payment_notifications) }
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
  end

  describe "Validations" do
    it{ should validate_presence_of(:project) }
    it{ should validate_presence_of(:user) }
    it{ should validate_presence_of(:value) }
    it{ should_not allow_value(9.99).for(:value) }
    it{ should allow_value(10).for(:value) }
    it{ should allow_value(20).for(:value) }
  end

  describe ".confirmed_today" do
    let(:backer1) { create(:backer, state: 'confirmed', confirmed_at: '2014-01-14') }
    let(:backer2) { create(:backer, state: 'confirmed', confirmed_at: '2014-01-15 00:00:00') }
    let(:backer3) { create(:backer, state: 'confirmed', confirmed_at: '2014-01-15 23:59:59') }
    subject { Timecop.freeze(Time.zone.local(2014,1,15,21,30)) { Backer.confirmed_today.order(:confirmed_at) } }
    it { should == [backer2, backer3] }
  end

  describe ".between_values" do
    let(:start_at) { 10 }
    let(:ends_at) { 20 }
    subject { Backer.between_values(start_at, ends_at) }
    before do
      create(:backer, value: 10)
      create(:backer, value: 15)
      create(:backer, value: 20)
      create(:backer, value: 21)
    end
    it { should have(3).itens }
  end

  describe ".can_cancel" do
    subject { Backer.can_cancel}

    context "when backer is in time to wait the confirmation" do
      before do
        create(:backer, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
      end
      it { should have(0).item }
    end

    context "when backer is by bank transfer and is passed the confirmation time" do
      before do
        create(:backer, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 2.weekdays_ago)
        create(:backer, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 0.weekdays_ago)
      end
      it { should have(1).item }
    end

    context "when we have backers that is passed the confirmation time" do
      before do
        create(:backer, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
        create(:backer, state: 'waiting_confirmation', created_at: 6.weekdays_ago)
      end
      it { should have(1).itens }
    end
  end

  describe "#update_current_billing_info" do
    let(:backer) { build(:backer, user: user) }
    let(:user) {
      build(:user, {
        address_street: 'test stret',
        address_number: '123',
        address_neighbourhood: 'test area',
        address_zip_code: 'test zipcode',
        address_city: 'test city',
        address_state: 'test state',
        phone_number: 'test phone',
        cpf: 'test doc number'
      })
    }
    subject{ backer }
    before do
      backer.update_current_billing_info
    end
    its(:payer_name) { should eq(user.display_name) }
    its(:address_street){ should eq(user.address_street) }
    its(:address_number){ should eq(user.address_number) }
    its(:address_neighbourhood){ should eq(user.address_neighbourhood) }
    its(:address_zip_code){ should eq(user.address_zip_code) }
    its(:address_city){ should eq(user.address_city) }
    its(:address_state){ should eq(user.address_state) }
    its(:address_phone_number){ should eq(user.phone_number) }
    its(:payer_document){ should eq(user.cpf) }
  end

  describe "#update_user_billing_info" do
    let(:backer) { create(:backer) }
    let(:user) { backer.user }
    let(:backer_attributes) {
      {
        address_street: backer.address_street,
        address_number: backer.address_number,
        address_neighbourhood: backer.address_neighbourhood,
        address_zip_code: backer.address_zip_code,
        address_city: backer.address_city,
        address_state: backer.address_state,
        phone_number: backer.address_phone_number,
        cpf: backer.payer_document
      }
    }

    before do
      user.should_receive(:update_attributes).with(backer_attributes)
    end

    it("should update user billing info attributes") { backer.update_user_billing_info}
  end

  describe '#recommended_projects' do
    subject{ backer.recommended_projects }
    let(:backer){ create(:backer) }

    context "when we have another projects in the same category" do
      before do
        @recommended = create(:project, category: backer.project.category)
        # add a project successful that should not apear as recommended
        create(:project, category: backer.project.category, state: 'successful')
      end
      it{ should eq [@recommended] }
    end

    context "when another user has backed the same project" do
      before do
        @another_backer = create(:backer, project: backer.project)
        @recommended = create(:backer, user: @another_backer.user).project
        # add a project successful that should not apear as recommended
        create(:backer, user: @another_backer.user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should eq [@recommended] }
    end
  end


  describe ".can_refund" do
    subject{ Backer.can_refund.load }
    before do
      create(:backer, state: 'confirmed', credits: true, project: failed_project)
      valid_refund
      sucessful_project_backer
      unfinished_project
      not_confirmed_backer
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end
    it{ should == [valid_refund] }
  end

  describe "#can_refund?" do
    subject{ backer.can_refund? }
    before do
      valid_refund
      sucessful_project_backer
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end

    context "when project is successful" do
      let(:backer){ sucessful_project_backer }
      it{ should be_false }
    end

    context "when project is not finished" do
      let(:backer){ unfinished_project_backer }
      it{ should be_false }
    end

    context "when backer is not confirmed" do
      let(:backer){ not_confirmed_backer }
      it{ should be_false }
    end

    context "when it's a valid refund" do
      let(:backer){ valid_refund }
      it{ should be_true }
    end
  end

  describe "#credits" do
    subject{ user.credits.to_f }
    context "when backs are confirmed and not done with credits but project is successful" do
      before do
        create(:backer, state: 'confirmed', user: user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should == 0 }
    end

    context "when backs are confirmed and not done with credits" do
      before do
        create(:backer, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 10 }
    end

    context "when backs are done with credits" do
      before do
        create(:backer, credits: true, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end

    context "when backs are not confirmed" do
      before do
        create(:backer, user: user, project: failed_project, state: 'pending')
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end
  end
end
