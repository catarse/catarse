# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'

module Transfeera
  class HttpRequest
    def execute(request_options)
      Typhoeus::Request.new(
        request_options[:url],
        params: request_options[:query] || {},
        body: request_options.fetch(:data, nil),
        headers: request_options.fetch(:headers, {}),
        method: request_options.fetch(:method, 'GET').downcase.to_sym
      ).run
    end
  end
end
