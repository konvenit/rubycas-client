Gem::Specification.new do |s|
  s.name = %q{rubycas-client}
  s.version = "2.0.9997.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Zukowski", "Matt Walker"]
  s.date = %q{2008-11-18}
  s.description = %q{Client library for the Central Authentication Service (CAS) protocol.}
  s.email = %q{matt at roughest dot net}
  s.extra_rdoc_files = ["CHANGELOG.txt", "History.txt", "LICENSE.txt", "Manifest.txt", "README.md"]
  s.files = ["CHANGELOG.txt", "History.txt", "LICENSE.txt", "Manifest.txt", "README.md", "Rakefile", "init.rb", "lib/casclient.rb", "lib/casclient/client.rb",
  "lib/casclient/frameworks/rails/cas_proxy_callback_controller.rb", "lib/casclient/frameworks/rails/request_handler.rb", "lib/casclient/frameworks/rails/filter.rb", "lib/casclient/responses.rb", "lib/casclient/tickets.rb", "lib/casclient/version.rb", "lib/rubycas-client.rb", "setup.rb"]
  s.homepage = %q{http://rubycas-client.rubyforge.org}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rubycas-client}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Client library for the Central Authentication Service (CAS) protocol.}

  s.add_dependency("activesupport")
end
