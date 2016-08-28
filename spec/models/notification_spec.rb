require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:project) { create(:project) }
  let(:notification) do
    create(:notification, metadata: {
      associations: {
        project_id: project.id
      },
      from_name: 'from_name',
      from_email: 'from@email.com',
      locale: 'pt'
    })
  end

  before do
    Sidekiq::Testing.inline!
  end

  describe 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe "#deliver" do
    before do
      allow(notification).to receive(:deliver!).and_return(true)
    end

    context "when notification already sent" do
      before do
        expect(notification).not_to receive(:deliver!)
        notification.update_attribute(:sent_at, DateTime.now)
      end
      it { notification.deliver }
    end

    context "when not sent notification" do
      before do
        expect(notification).to receive(:deliver!)
      end
      it { notification.deliver }
    end
  end

  describe "#deliver!" do
    before do
      allow(EmailWorker).to receive(:perform_at).and_call_original
      allow(Notification).to receive(:find).with(notification.id).and_return(notification)
      allow(notification).to receive(:deliver_without_worker).and_return(true)

      expect(EmailWorker).to receive(:perform_at).and_call_original
      expect(notification).to receive(:deliver_without_worker)
    end

    it "should perform email worker to deliver notification" do
      expect(notification.sent_at).to eq(nil)
      notification.deliver!
      notification.reload
      expect(notification.sent_at).not_to be_nil
    end
  end

  describe '#deliver_without_worker' do
    it "should use mailer deliveries" do
      expect {
       notification.deliver_without_worker
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#mailer' do
    subject { notification.mailer }
    it { is_expected.to eq(Notifier) }
  end

  describe 'from metadata attributes' do
    describe '#project' do
      subject { notification.project }
      it { is_expected.to eq(project) }
    end

    describe '#from_name' do
      subject { notification.from_name }
      it { is_expected.to eq('from_name') }
    end

    describe '#from_email' do
      subject { notification.from_email}
      it { is_expected.to eq('from@email.com') }
    end

    describe '#locale' do
      subject { notification.locale}
      it { is_expected.to eq('pt') }
    end
  end
end
