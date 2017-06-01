# frozen_string_literal: true

SimpleTokenAuthentication.configure do |config|
  # Configure the session persistence policy after a successful sign in.
  config.sign_in_token = true
end
