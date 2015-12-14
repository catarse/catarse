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
    it { is_expected.to have_many(:payments) }
    it { is_expected.to have_many(:details) }
    it { is_expected.to belong_to(:origin) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reward) }
    it { is_expected.to belong_to(:country) }
  end

  describe "Validations" do
    it{ is_expected.to validate_presence_of(:payer_email) }
    it{ is_expected.to validate_presence_of(:project) }
    it{ is_expected.to validate_presence_of(:user) }
    it{ is_expected.to validate_presence_of(:value) }
    it{ is_expected.to_not allow_value(9).for(:value) }
    it{ is_expected.to allow_value(10).for(:value) }
    it{ is_expected.to allow_value(20).for(:value) }
  end

  describe ".confirmed_last_day" do
    before do
      3.times { create(:payment, state: 'paid', paid_at: 2.days.ago) }
      4.times { create(:payment, state: 'paid', paid_at: 6.days.ago) }

      #TODO: need to investigate this timestamp issue when
      # use DateTime.now or Time.now
      7.times { create(:payment, state: 'paid', paid_at: Time.now) }
    end

    subject { Contribution.confirmed_last_day }

    it { is_expected.to have(7).items }
  end

  describe '#pending?' do
    subject{ contribution.pending? }
    context "when contribution has no pending payment" do
      let(:contribution){ create(:confirmed_contribution) }
      it{ is_expected.to eq false }
    end

    context "when contribution has pending payment" do
      let(:contribution){ create(:pending_contribution) }
      it{ is_expected.to eq true }
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

  describe "#was_confirmed?" do
    subject{ contribution.was_confirmed? }

    context "when I have one payment with state paid" do
      let(:contribution){ create(:confirmed_contribution) }
      it{ is_expected.to eq true }
    end

    context "when I have one payment with state refunded" do
      let(:contribution){ create(:refunded_contribution) }
      it{ is_expected.to eq true }
    end

    context "when I have one payment with state pending" do
      let(:contribution){ create(:pending_contribution) }
      it{ is_expected.to eq false }
    end
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

  describe ".need_notify_about_pending_refund" do
    let(:project) { create(:project) }
    let(:refunded_contribution) { create(:refunded_contribution, project: project) }
    let(:paid_contribution) { create(:confirmed_contribution, project: project) }

    subject { Contribution.need_notify_about_pending_refund }
    before do
      paid_contribution.payments.first.update_attributes({payment_method: 'BoletoBancario'})
      refunded_contribution
      project.update_column(:state, 'failed')
    end

    context "when not receive a pending notification" do
      it "should find the contributions that need to be notified" do
        is_expected.to eq([paid_contribution])
      end
    end

    context "when notifications already passed 7 days" do
      before do
        paid_contribution.notify(
          :contribution_project_unsuccessful_slip_no_account,
          paid_contribution.user)
        paid_contribution.notifications.last.update_column(:created_at, 8.days.ago)
      end
      it "should not find the contributions that need to be notified" do
        is_expected.to eq([paid_contribution])
      end
    end

    context "when already notified" do
      before do
        paid_contribution.notify(
          :contribution_project_unsuccessful_slip_no_account,
          paid_contribution.user)
      end
      it "should not find the contributions that need to be notified" do
        is_expected.to eq([])
      end
    end

  end
end
