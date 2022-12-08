require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RubycasClientApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Override default rails_root
    config.root = File.expand_path('../..', __FILE__)

    # Custom directories with classes and modules you want to be autoloadable.
#    config.autoload_paths += %W(#{config.root}/app/games #{config.root}/app/games/strategies #{config.root}/app/support #{config.root}/app/workers)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end

