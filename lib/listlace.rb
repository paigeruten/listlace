require "ruby-mpd"

require "listlace/core_ext/array"

require "listlace/commands"
require "listlace/selectors"

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

