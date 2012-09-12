Gem::Specification.new do |s|
  s.name = "listlace"
  s.version = "0.0.8"
  s.date = "2012-09-07"
  s.summary = "A music player in a REPL."
  s.description = "Listlace is a music player which is interacted with through a Ruby REPL."
  s.author = "Jeremy Ruten"
  s.email = "jeremy.ruten@gmail.com"
  s.homepage = "http://github.com/yjerem/listlace"
  s.license = "MIT"
  s.required_ruby_version = ">= 1.9.2"
  s.requirements << "mplayer"
  s.requirements << "taglib"
  s.executables << "listlace"

  s.files = ["Gemfile", "Gemfile.lock", "LICENSE", "listlace.gemspec", "README.md", "README.old"]
  s.files += ["bin/listlace"]
  s.files += Dir["lib/**/*.rb"]

  %w(pry plist sqlite3 activerecord activesupport open4 taglib-ruby).each do |gem_name|
    s.add_runtime_dependency gem_name
  end

  %w(rake).each do |gem_name|
    s.add_development_dependency gem_name
  end
end
