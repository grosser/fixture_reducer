name = "fixture_reducer"
require "./lib/#{name}/version"

Gem::Specification.new name, FixtureReducer::VERSION do |s|
  s.summary = "Test speedup by replacing fixtures :all with only the necessary"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib bin`.split("\n")
  s.license = "MIT"
  s.executables = ["fixture-reducer"]
end
