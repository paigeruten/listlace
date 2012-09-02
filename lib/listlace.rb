require "open4"
require "active_record"
require "fileutils"
require "plist"
require "active_support/core_ext/string"

require "listlace/core_ext/array"

require "listlace/models/track"
require "listlace/models/playlist"
require "listlace/models/playlist_item"

require "listlace/library"
require "listlace/library/database"
require "listlace/library/selectors"

require "listlace/single_player"
require "listlace/single_players/mplayer"
require "listlace/player"

require "listlace/commands/library_commands"
require "listlace/commands/player_commands"

module Listlace
  extend Listlace::Library::Selectors

  class << self
    attr_accessor :library, :player
  end

  DIR = ENV["LISTLACE_DIR"] || (ENV["HOME"] + "/.listlace")
end
