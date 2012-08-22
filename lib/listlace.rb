require "mplayer-ruby"
require "active_record"

Dir["./**/*.rb"].each { |f| require f }

# gotta ged rid of this global sometime
$player = Listlace::Player.new

module Listlace
  extend self

  PROMPT = [proc { ">> " }, proc { " | " }]
end

at_exit do
  Listlace.stop
end
