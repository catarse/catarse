# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::NotificationsWithoutSendgridEvent do
  let!(:notifications) do
    [
      create(:project_notification, created_at: 4.days.ago),
      create(:notification, created_at: 6.hours.ago),
      create(:project_notification, created_at: 1.month.ago),
      create(:notification, created_at: Time.zone.now)
    ]
  end

  before do
    create(:sendgrid_event, notification_id: create(:project_notification).id,
      notification_type: 'ProjectNotification'
    )
    create(:sendgrid_event, notification_id: create(:notification).id, notification_type: 'Notification')
  end

  describe '#call' do
    context 'when the query is successfull' do
      it 'doesn`t capture message via Sentry' do
        expect(Sentry).not_to receive(:capture_message)

        described_class.new.call
      end

      it 'return expected notifications' do
        expect(described_class.new.call).to eq([notifications[0], notifications[1]])
      end
    end

    context 'when the query fails' do
      let(:exception) { RuntimeError.new('Error') }

      before do
        allow(SendgridEvent).to receive(:distinct).and_raise(exception)
      end

      it 'captures error message via Sentry' do
        expect(Sentry).to receive(:capture_exception).with(exception, level: :fatal)

        described_class.new.call
      end
    end
  end
end
