require "mpd_client"

require "listlace/commands"

class Listlace
  attr_reader :mpd

  include Commands

  def initialize(host, port)
    @mpd = MPDClient.new
    @mpd.connect(host, port)
  end

  def disconnect
    @mpd.disconnect
  end
end

