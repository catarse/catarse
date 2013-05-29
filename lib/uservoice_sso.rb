require 'ezcrypto'
require 'json'
require 'cgi'
require 'base64'

module Uservoice
  class Token
    attr_accessor :data

    def self.generate(options = {})
      options.merge!({expires: (Time.zone.now.utc+5*60).to_s})

      key = EzCrypto::Key.with_password ::Configuration[:uservoice_subdomain], ::Configuration[:uservoice_sso_key]
      encrypted = key.encrypt(options.to_json)
      @data = Base64.encode64(encrypted).gsub(/\n/, '')

      @data.to_s
    end
  end
end
