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
      nil
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

    def list(playlist = nil)
      (playlist || all).each do |song|
        time = TimeHelpers.format_time(song.time)
        puts "#{song.artist} - #{song.album} - #{song.title} (#{time})"
      end
      nil
    end

    def artists(playlist = nil)
      (playlist || all).group_by(&:artist).each do |artist, songs|
        plural = (songs.length == 1) ? "" : "s"
        puts "#{artist} (#{songs.length} song#{plural})"
      end
      nil
    end

    def albums(playlist = nil)
      (playlist || all).group_by(&:album).each do |album, songs|
        plural = (songs.length == 1) ? "" : "s"
        puts "#{songs.first.artist} - #{album} (#{songs.length} song#{plural})"
      end
      nil
    end

    def genres(playlist = nil)
      (playlist || all).group_by(&:genre).each do |genre, songs|
        plural = (songs.length == 1) ? "" : "s"
        puts "#{genre} (#{songs.length} song#{plural})"
      end
      nil
    end

    def years(playlist = nil)
      (playlist || all).group_by(&:date).each do |year, songs|
        plural = (songs.length == 1) ? "" : "s"
        puts "#{year} (#{songs.length} song#{plural})"
      end
      nil
    end
  end
end

