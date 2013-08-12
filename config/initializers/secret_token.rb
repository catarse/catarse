# Be sure to restart your server when you modify this file.
require 'securerandom'
# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
def find_secure_token
  ::Configuration[:secret_token] = SecureRandom.hex(64) unless ::Configuration[:secret_token]
  ::Configuration[:secret_token]
rescue
  # Just to ensure that we can run migrations and create the configurations table
  nil
end

Catarse::Application.config.secret_token = find_secure_token 

