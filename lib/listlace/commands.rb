class Listlace
  module Commands
    def p(*playlist)
      if playlist.empty?
        case mpd.status[:state]
        when :play
          mpd.pause = true
        when :pause
          mpd.pause = false
        when :stop
          mpd.play
        end
      else
        mpd.clear
        playlist.flatten.each do |song|
          mpd.add song.file
        end
        mpd.play
      end
      nil
    end

    def stop
      mpd.stop
    end

    def q(*playlist)
      if playlist.empty?
        mpd.queue
      else
        mpd.clear
        playlist.flatten.each do |song|
          mpd.add song.file
        end
        nil
      end
    end
  end
end

