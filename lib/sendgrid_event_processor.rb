class SendgridEventProcessor
  def call(event)
    SendgridEvent.create! sendgrid_data: event.attributes.to_json
  end
end
