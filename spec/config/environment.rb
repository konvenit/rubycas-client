RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.action_controller.session = {
    :session_key => '_rubycas_client_session',
    :secret      => 'e8fc6518178886971dd098ca6f6e3e7a8d7c75440069aa6724284682cc2b9745cdf4a0979b417906ca4f2f2ec1fe89bf935a7230c03604a842b0d8110860f21e'
  }

end
