ENV["RAILS_ENV"] = "test"

require "rails/all"

class RubycasClientApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.eager_load = false
  config.session_store :cookie_store, key: "_rails_session"
  config.secret_token = "095f674153982a9ce59914b561f4522a"
  config.logger = Logger.new("/dev/null")
end

ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: "konvenit.sqlite3.db",
  timeout:  150000
)

require_relative "app/controllers/application_controller"

require "rspec"
require "rspec/rails"
require "rspec/expectations"
# load test helpers
require File.expand_path(File.dirname(__FILE__) + "/extensions")

# include the plugin code
require File.expand_path(File.dirname(__FILE__) + "/../init")
