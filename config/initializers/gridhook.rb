Gridhook.configure do |config|
  config.event_receive_path = '/sendgrid/event'

  config.event_processor = SendgridEventProcessor.new
end
