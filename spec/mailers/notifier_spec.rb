require "rails_helper"

RSpec.describe Notifier, type: :mailer do
  let(:project) { create(:project) }
  let(:notification_with_user) do
    create(:notification,
      user: create(:user),
      metadata: {
      associations: {
        project_id: project.id
      },
      from_name: 'from_name',
      from_email: 'from@email.com',
      locale: 'pt'
    })
  end

  let(:notification) do
    create(:notification,
      user: nil,
      user_email: 'user@email.com',
      metadata: {
      associations: {
        project_id: project.id
      },
      from_name: 'from_name',
      from_email: 'from@email.com',
      locale: 'pt'
    })
  end

  describe '.notify' do
    context "when notification not have a user relation" do
      subject { Notifier.notify(notification) }
      its(:to) { is_expected.to eq(['user@email.com']) }
      its(:from) { is_expected.to eq([CatarseSettings[:email_system]]) }
      its(:reply_to) { is_expected.to eq(['from@email.com']) }

      it 'should set x-smtpapi headers' do
        unique_args = ActiveSupport::JSON.decode(subject['X-SMTPAPI'].value)["unique_args"]
        expect(unique_args['notification_user']).to eq(nil)
        expect(unique_args['notification_type']).to eq('Notification')
        expect(unique_args['notification_id']).to eq(notification.id)
        expect(unique_args['template_name']).to eq(notification.template_name)
      end
    end

    context "when notification have an user relation" do
      subject { Notifier.notify(notification_with_user) }
      its(:to) { is_expected.to eq([notification_with_user.user.email]) }
      its(:from) { is_expected.to eq([CatarseSettings[:email_system]]) }
      its(:reply_to) { is_expected.to eq(['from@email.com']) }

      it 'should set x-smtpapi headers' do
        unique_args = ActiveSupport::JSON.decode(subject['X-SMTPAPI'].value)["unique_args"]
        expect(unique_args['notification_user']).to eq(notification_with_user.user_id)
        expect(unique_args['notification_type']).to eq('Notification')
        expect(unique_args['notification_id']).to eq(notification_with_user.id)
        expect(unique_args['template_name']).to eq(notification_with_user.template_name)
      end
    end
  end
end
