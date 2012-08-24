module Listlace
  class Track < ActiveRecord::Base
    has_many :playlist_items
    has_many :playlists, through: :playlist_items

    def formatted_total_time
      Track.format_time(total_time)
    end

    def play
      $player.queue = [self]
      Listlace.play
    end

    def self.format_time(milliseconds)
      total_seconds = milliseconds / 1000

      seconds = total_seconds % 60
      minutes = (total_seconds / 60) % 60
      hours = total_seconds / 3600

      if hours > 0
        "%d:%02d:%02d" % [hours, minutes, seconds]
      else
        "%d:%02d" % [minutes, seconds]
      end
    end
  end
end
