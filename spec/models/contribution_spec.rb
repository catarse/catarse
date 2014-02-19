require 'spec_helper'

describe Contribution do
  let(:user){ create(:user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:unfinished_project_contribution){ create(:contribution, state: 'confirmed', user: user, project: unfinished_project) }
  let(:sucessful_project_contribution){ create(:contribution, state: 'confirmed', user: user, project: successful_project) }
  let(:not_confirmed_contribution){ create(:contribution, user: user, project: unfinished_project) }
  let(:valid_refund){ create(:contribution, state: 'confirmed', user: user, project: failed_project) }


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
    before do
      3.times { create(:contribution, state: 'confirmed', confirmed_at: 2.days.ago) }
      4.times { create(:contribution, state: 'confirmed', confirmed_at: 6.days.ago) }

      #TODO: need to investigate this timestamp issue when
      # use DateTime.now or Time.now
      7.times { create(:contribution, state: 'confirmed', confirmed_at: Time.now) }
    end

    subject { Contribution.confirmed_today }

    it { should have(7).items }
  end

  describe ".between_values" do
    let(:start_at) { 10 }
    let(:ends_at) { 20 }
    subject { Contribution.between_values(start_at, ends_at) }
    before do
      create(:contribution, value: 10)
      create(:contribution, value: 15)
      create(:contribution, value: 20)
      create(:contribution, value: 21)
    end
    it { should have(3).itens }
  end

  describe ".can_cancel" do
    subject { Contribution.can_cancel}

    context "when contribution is in time to wait the confirmation" do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
      end
      it { should have(0).item }
    end

    context "when contribution is by bank transfer and is passed the confirmation time" do
      before do
        create(:contribution, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 2.weekdays_ago)
        create(:contribution, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 0.weekdays_ago)
      end
      it { should have(1).item }
    end

    context "when we have contributions that is passed the confirmation time" do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
        create(:contribution, state: 'waiting_confirmation', created_at: 6.weekdays_ago)
      end
      it { should have(1).itens }
    end
  end

  describe '#slip_payment?' do
    let(:contribution) { create(:contribution, payment_choice: 'BoletoBancario')}

    subject { contribution.slip_payment? }

    context "when contribution is made with Boleto" do
      it { should be_true}
    end

    context "when contribution is not made with Boleto" do
      let(:contribution) { create(:contribution, payment_choice: 'CartaoDeCredito')}
      it { should be_false}
    end
  end

  describe "#update_current_billing_info" do
    let(:contribution) { build(:contribution, user: user) }
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
    subject{ contribution }
    before do
      contribution.update_current_billing_info
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
    let(:contribution) { create(:contribution) }
    let(:user) { contribution.user }
    let(:contribution_attributes) {
      {
        address_street: contribution.address_street,
        address_number: contribution.address_number,
        address_neighbourhood: contribution.address_neighbourhood,
        address_zip_code: contribution.address_zip_code,
        address_city: contribution.address_city,
        address_state: contribution.address_state,
        phone_number: contribution.address_phone_number,
        cpf: contribution.payer_document
      }
    }

    before do
      user.should_receive(:update_attributes).with(contribution_attributes)
    end

    it("should update user billing info attributes") { contribution.update_user_billing_info}
  end

  describe '#recommended_projects' do
    subject{ contribution.recommended_projects }
    let(:contribution){ create(:contribution) }

    context "when we have another projects in the same category" do
      before do
        @recommended = create(:project, category: contribution.project.category)
        # add a project successful that should not apear as recommended
        create(:project, category: contribution.project.category, state: 'successful')
      end
      it{ should eq [@recommended] }
    end

    context "when another user has contributed the same project" do
      before do
        @another_contribution = create(:contribution, project: contribution.project)
        @recommended = create(:contribution, user: @another_contribution.user).project
        # add a project successful that should not apear as recommended
        create(:contribution, user: @another_contribution.user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should eq [@recommended] }
    end
  end


  describe ".can_refund" do
    subject{ Contribution.can_refund.load }
    before do
      create(:contribution, state: 'confirmed', credits: true, project: failed_project)
      valid_refund
      sucessful_project_contribution
      unfinished_project
      not_confirmed_contribution
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end
    it{ should == [valid_refund] }
  end

  describe "#can_refund?" do
    subject{ contribution.can_refund? }
    before do
      valid_refund
      sucessful_project_contribution
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end

    context "when project is successful" do
      let(:contribution){ sucessful_project_contribution }
      it{ should be_false }
    end

    context "when project is not finished" do
      let(:contribution){ unfinished_project_contribution }
      it{ should be_false }
    end

    context "when contribution is not confirmed" do
      let(:contribution){ not_confirmed_contribution }
      it{ should be_false }
    end

    context "when it's a valid refund" do
      let(:contribution){ valid_refund }
      it{ should be_true }
    end
  end

  describe "#credits" do
    subject{ user.credits.to_f }
    context "when contributions are confirmed and not done with credits but project is successful" do
      before do
        create(:contribution, state: 'confirmed', user: user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ should == 0 }
    end

    context "when contributions are confirmed and not done with credits" do
      before do
        create(:contribution, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 10 }
    end

    context "when contributions are done with credits" do
      before do
        create(:contribution, credits: true, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end

    context "when contributions are not confirmed" do
      before do
        create(:contribution, user: user, project: failed_project, state: 'pending')
        failed_project.update_attributes state: 'failed'
      end
      it{ should == 0 }
    end
  end
end
