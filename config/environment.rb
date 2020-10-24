# frozen_string_literal: true

# Load the rails application
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
env_db_timeout = ENV['DB_STATEMENT_TIMEOUT'].presence || '5500'
ActiveRecord::Base.connection.execute("set statement_timeout to #{env_db_timeout}") if Rails.env.production?
