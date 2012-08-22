module Listlace
  class Track < ActiveRecord::Base
    has_many :playlist_items
    has_many :playlists, through: :playlist_items

    def path
      CGI::unescape(location.sub(/^file:\/\/localhost/, ""))
    end

    def formatted_total_time
      total_seconds = total_time / 1000

      seconds = total_seconds % 60
      minutes = (total_seconds / 60) % 60
      hours = total_seconds / 3600

      if hours > 0
        "%d:%02d:%02d" % [hours, minutes, seconds]
      else
        "%d:%02d" % [minutes, seconds]
      end
    end

    def play
      Listlace.stop
      $playlist = [self]
      Listlace.play
    end
  end
end
