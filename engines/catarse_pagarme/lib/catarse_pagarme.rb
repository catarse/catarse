# frozen_string_literal: true

require "pagarme"
require "konduto-ruby"
require "catarse_pagarme/engine"
require "catarse_pagarme/configuration"
require "catarse_pagarme/payment_engine"
require "sidekiq"

module CatarsePagarme
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
