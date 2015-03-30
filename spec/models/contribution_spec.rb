require 'rails_helper'

RSpec.describe Contribution, type: :model do
  let(:user){ create(:user) }
  let(:failed_project){ create(:project, state: 'online') }
  let(:unfinished_project){ create(:project, state: 'online') }
  let(:successful_project){ create(:project, state: 'online') }
  let(:unfinished_project_contribution){ create(:confirmed_contribution, user: user, project: unfinished_project) }
  let(:sucessful_project_contribution){ create(:confirmed_contribution, user: user, project: successful_project) }
  let(:not_confirmed_contribution){ create(:contribution, user: user, project: unfinished_project) }
  let(:valid_refund){ create(:confirmed_contribution, user: user, project: failed_project) }
  let(:contribution) { create(:contribution) }


  describe "Associations" do
    it { is_expected.to have_many(:payment_notifications) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reward) }
    it { is_expected.to belong_to(:country) }
  end

  describe "Validations" do
    it{ is_expected.to validate_presence_of(:project) }
    it{ is_expected.to validate_presence_of(:user) }
    it{ is_expected.to validate_presence_of(:value) }
    it{ is_expected.to_not allow_value(9).for(:value) }
    it{ is_expected.to allow_value(10).for(:value) }
    it{ is_expected.to allow_value(20).for(:value) }
  end


  describe '.for_successful_projects' do
    let(:project) { create(:project, goal: 200, state: 'online') }

    subject { Contribution.for_successful_projects }

    before do
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 10)
      create(:contribution, value: 100, project: project)

      project.update_attributes(state: 'successful')
    end

    it { is_expected.to have(2).itens }
  end

  describe '.for_failed_projects' do
    let(:project) { create(:project, goal: 200) }

    subject { Contribution.for_failed_projects }

    before do
      create(:confirmed_contribution, project: project)
      create(:confirmed_contribution, project: project)
      create(:pending_refund_contribution, project: project)
      create(:refunded_contribution, project: project)
      create(:confirmed_contribution)
      create(:contribution, project: project)
      project.update_attributes(state: 'failed')
    end

    it { is_expected.to have(4).itens }
  end

  describe '.not_created_today' do
    before do
      create(:contribution, created_at: 1.day.ago)
      create(:contribution, created_at: 2.day.ago)
      create(:contribution, created_at: 10.minutes.ago)
    end

    subject { Contribution.not_created_today }

    it { is_expected.to have(2).itens }
  end

  describe ".avaiable_to_automatic_refund" do
    before do
      @confirmed = create(:confirmed_contribution)
      create(:pending_contribution)
      create(:contribution)
    end

    subject { Contribution.avaiable_to_automatic_refund }

    it { is_expected.to eq [@confirmed] }
  end

  describe ".confirmed_today" do
    before do
      3.times { create(:payment, state: 'paid', paid_at: 2.days.ago) }
      4.times { create(:payment, state: 'paid', paid_at: 6.days.ago) }

      #TODO: need to investigate this timestamp issue when
      # use DateTime.now or Time.now
      7.times { create(:payment, state: 'paid', paid_at: Time.now) }
    end

    subject { Contribution.confirmed_today }

    it { is_expected.to have(7).items }
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
    it { is_expected.to have(3).itens }
  end

  describe ".can_cancel" do
    subject { Contribution.can_cancel}

    context "when contribution is in time to wait the confirmation" do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
      end
      it { is_expected.to have(0).item }
    end

    context "when contribution is by bank transfer and is passed the confirmation time" do
      before do
        create(:contribution, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 2.weekdays_ago)
        create(:contribution, state: 'waiting_confirmation', payment_choice: 'DebitoBancario', created_at: 0.weekdays_ago)
      end
      it { is_expected.to have(1).item }
    end

    context "when we have contributions that is passed the confirmation time" do
      before do
        create(:contribution, state: 'waiting_confirmation', created_at: 3.weekdays_ago)
        create(:contribution, state: 'waiting_confirmation', created_at: 6.weekdays_ago)
      end
      it { is_expected.to have(1).itens }
    end
  end

  describe '#recommended_projects' do
    let(:contribution){ create(:confirmed_contribution) }
    subject{ contribution.recommended_projects }

    context "when we have another projects in the same category" do
      before do
        @recommended = create(:project, category: contribution.project.category)
        # add a project successful that should not apear as recommended
        create(:project, category: contribution.project.category, state: 'successful')
      end
      it{ is_expected.to eq [@recommended] }
    end

    context "when another user has contributed the same project" do
      before do
        @another_contribution = create(:confirmed_contribution, project: contribution.project)
        @recommended = create(:confirmed_contribution, user: @another_contribution.user).project
        # add a project successful that should not apear as recommended
        create(:confirmed_contribution, user: @another_contribution.user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ is_expected.to eq [@recommended] }
    end
  end


  describe ".can_refund" do
    subject{ Contribution.can_refund.load }
    before do
      valid_refund
      sucessful_project_contribution
      unfinished_project
      not_confirmed_contribution
      successful_project.update_attributes state: 'successful'
      failed_project.update_attributes state: 'failed'
    end
    it{ is_expected.to eq([valid_refund]) }
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
      it{ is_expected.to eq(false) }
    end

    context "when project is not finished" do
      let(:contribution){ unfinished_project_contribution }
      it{ is_expected.to eq(false) }
    end

    context "when contribution is not confirmed" do
      let(:contribution){ not_confirmed_contribution }
      it{ is_expected.to eq(false) }
    end

    context "when it's a valid refund" do
      let(:contribution){ valid_refund }
      it{ is_expected.to eq(true) }
    end
  end

  describe "#credits" do
    subject{ user.credits.to_f }
    context "when contributions are confirmed and not done with credits but project is successful" do
      before do
        create(:contribution, state: 'confirmed', user: user, project: successful_project)
        successful_project.update_attributes state: 'successful'
      end
      it{ is_expected.to eq(0) }
    end

    context "when contributions are confirmed and not done with credits" do
      before do
        contribution = create(:contribution, user: user, project: failed_project)
        contribution.payments << create(:payment, state: 'paid', value: 10, gateway: 'AnyButCredits')
        failed_project.update_attributes state: 'failed'
        user.reload
      end
      it{ is_expected.to eq(10) }
    end

    context "when contributions are done with credits" do
      before do
        create(:contribution, credits: true, state: 'confirmed', user: user, project: failed_project)
        failed_project.update_attributes state: 'failed'
      end
      it{ is_expected.to eq(0) }
    end

    context "when contributions are not confirmed" do
      before do
        create(:contribution, user: user, project: failed_project, state: 'pending')
        failed_project.update_attributes state: 'failed'
      end
      it{ is_expected.to eq(0) }
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
    its(:payer_name) { should eq(user.name) }
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
    let(:user) { contribution.user }
    let(:contribution) { create(:contribution) }
    let(:contribution_attributes) {
      {
        country_id: (contribution.country_id || user.country_id),
        address_street: (contribution.address_street || user.address_street),
        address_number: (contribution.address_number || user.address_number),
        address_complement: (contribution.address_complement || user.address_complement),
        address_neighbourhood: (contribution.address_neighbourhood || user.address_neighbourhood),
        address_zip_code: (contribution.address_zip_code || user.address_zip_code),
        address_city: (contribution.address_city || user.address_city),
        address_state: (contribution.address_state || user.address_state),
        phone_number: (contribution.address_phone_number || user.phone_number),
        cpf: (contribution.payer_document || user.cpf),
        name: (contribution.payer_name || user.name)
      }
    }

    before do
      contribution.update_attributes payer_document: '123'
      contribution.reload
      expect(user).to receive(:update_attributes).with(contribution_attributes)
    end

    it("should update user billing info attributes") { contribution.update_user_billing_info}
  end

  describe "#confirmed?" do
    subject{ contribution.confirmed? }

    context "when I have one payment with state paid" do
      let(:contribution){ create(:confirmed_contribution) }
      it{ is_expected.to eq true }
    end

    context "when I have one payment with state pending" do
      let(:contribution){ create(:pending_contribution) }
      it{ is_expected.to eq false }
    end
  end
end
