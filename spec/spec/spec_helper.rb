ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'rspec'
require 'rspec/rails'
require "rspec/expectations"

# load the schema into the db
load(File.join(File.dirname(__FILE__), "..", "config", "schema.rb"))

# load test helpers
require File.expand_path(File.dirname(__FILE__) + "/extensions")

# include the plugin code
require File.expand_path(File.dirname(__FILE__) + "/../../init")
