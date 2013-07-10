# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Catarse::Application.initialize!
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

