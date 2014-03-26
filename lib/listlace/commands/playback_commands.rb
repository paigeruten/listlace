class Listlace
  module Commands
    module PlaybackCommands
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
        nil
      end

      def skip(n = 1)
        n.times { mpd.next }
        nil
      end

      def back(n = 1)
        n.times { mpd.previous }
        nil
      end

      def restart
        seek_to 0
        nil
      end

      def pause
        mpd.pause = true
        nil
      end

      def resume
        mpd.pause = false
        nil
      end

      def seek(time)
        if time.is_a? String
          time = TimeHelpers.parse_time(time)
        end
        stat = mpd.status
        mpd.seek(stat[:time].first + time, pos: stat[:song])
        nil
      end

      def seek_to(time)
        if time.is_a? String
          time = TimeHelpers.parse_time(time)
        end
        mpd.seek(time, pos: mpd.status[:song])
        nil
      end
    end
  end
end

