module Listlace
  extend self

  DIR = ENV["LISTLACE_DIR"] || (ENV["HOME"] + "/.listlace")
  PROMPT = [proc { ">> " }, proc { " | " }]
end

require "mplayer-ruby"
require "active_record"

require "listlace/database"
require "listlace/player"

require "listlace/models/track"
require "listlace/models/playlist"
require "listlace/models/playlist_item"

require "listlace/commands/library"
require "listlace/commands/playback"
require "listlace/commands/selectors"
require "listlace/commands/volume"

# gotta ged rid of this global sometime
$player = Listlace::Player.new

at_exit do
  Listlace.stop
end
