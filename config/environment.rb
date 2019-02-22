# frozen_string_literal: true

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
Catarse::Application.initialize!
env_db_timeout = ENV['DB_STATEMENT_TIMEOUT'].presence || '5500'
ActiveRecord::Base.connection.execute("set statement_timeout to #{env_db_timeout}") if Rails.env.production?
