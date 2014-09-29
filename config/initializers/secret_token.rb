# Be sure to restart your server when you modify this file.
require 'securerandom'
# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
def find_secure_token
  CatarseSettings[:secret_token] = SecureRandom.hex(64) unless ::CatarseSettings.get_without_cache(:secret_token)
  CatarseSettings.get_without_cache(:secret_token)
rescue
  # Just to ensure that we can run migrations and create the settings table
  nil
end

def find_secure_key_base
  CatarseSettings[:secret_key_base] = SecureRandom.hex(64) unless ::CatarseSettings.get_without_cache(:secret_key_base)
  CatarseSettings.get_without_cache(:secret_key_base)
rescue
  # Just to ensure that we can run migrations and create the settings table
  nil
end

Catarse::Application.config.secret_token = find_secure_token
Catarse::Application.config.secret_key_base = find_secure_key_base
