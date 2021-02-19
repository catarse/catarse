# frozen_string_literal: true

begin
  OmniauthCallbacksController.add_providers
rescue StandardError
  nil
end
