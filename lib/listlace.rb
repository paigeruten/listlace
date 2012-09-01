require "open4"
require "active_record"
require "fileutils"
require "plist"
require "active_support/core_ext/string"

require "listlace/array_ext"
require "listlace/library"
require "listlace/player"
require "listlace/commands"
require "listlace/models"

module Listlace
  extend Listlace::Library::Selectors

  class << self
    attr_accessor :library, :player
  end

  DIR = ENV["LISTLACE_DIR"] || (ENV["HOME"] + "/.listlace")
end
