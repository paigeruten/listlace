class Listlace
  module Commands
    module InfoCommands
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
end

