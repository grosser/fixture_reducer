$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "fixture_reducer"
require "#{name.gsub("-","/")}/version"

Gem::Specification.new name, FixtureReducer::VERSION do |s|
  s.summary = "Test speedup by replacing fixtures :all with only the necessary"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem")
  s.cert_chain = [".public_cert.pem"]
end
