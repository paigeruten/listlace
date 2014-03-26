class Listlace
  module Commands
    module QueueCommands
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
end

