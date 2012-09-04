module Listlace
  # The bare minimum needed to represent a track. This is used by the Player and
  # SinglePlayer, in case they get passed a String containing a path to an audio
  # file. That way, users don't have to worry about creating track objects, if
  # they want.
  class SimpleTrack
    attr_accessor :location

    def initialize(location = nil)
      @location = location
    end
  end
end
