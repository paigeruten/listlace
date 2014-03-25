require "ruby-mpd"

require "listlace/commands"
require "listlace/selectors"
require "listlace/time_helpers"

require "listlace/core_ext/array"

class Listlace
  attr_reader :mpd

  include Commands
  include Selectors

  def initialize(host, port)
    @mpd = MPD.new(host, port)
    @mpd.connect
  end

  def disconnect
    @mpd.disconnect
  end
end

