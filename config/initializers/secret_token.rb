# Be sure to restart your server when you modify this file.
require 'securerandom'
# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
def find_secure_token
  token_file = Rails.root.join('.secret')
  if File.exist? token_file
    File.read(token_file).chomp
  else
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end

Catarse::Application.config.secret_token = find_secure_token 

