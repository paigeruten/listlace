Gem::Specification.new do |s|
  s.name = "listlace"
  s.version = "0.2.2"
  s.date = "2014-03-25"
  s.summary = "An mpd (music player daemon) client with a Ruby shell as the interface."
  s.description = "Listlace is an mpd (music player daemon) client with a Ruby shell as the interface."
  s.author = "Jeremy Ruten"
  s.email = "jeremy.ruten@gmail.com"
  s.homepage = "http://github.com/yjerem/listlace"
  s.license = "MIT"
  s.required_ruby_version = ">= 1.9.2"
  s.executables << "listlace"

  s.files = ["Gemfile", "Gemfile.lock", "LICENSE", "listlace.gemspec", "README.md"]
  s.files += ["bin/listlace"]
  s.files += Dir["lib/**/*.rb"]

  s.add_runtime_dependency "bundler", "~> 1.5"
  s.add_runtime_dependency "pry", "~> 0.9"
  s.add_runtime_dependency "ruby-mpd", "~> 0.3", ">= 0.3.1"
end

