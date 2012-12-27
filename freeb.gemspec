root = File.dirname(File.absolute_path(__FILE__))
require "#{root}/lib/freeb/version"

Gem::Specification.new do |s|
  s.name        = "freeb"
  s.version     = Freeb::VERSION
  s.authors     = ["Tom Benner"]
  s.email       = ["tombenner@gmail.com"]
  s.homepage    = "https://github.com/tombenner/freeb"
  s.summary     = "Store the world's knowledge in Rails models (via Freebase)"
  s.description = "Store the world's knowledge in Rails models (via Freebase)"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "httparty"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
