module Listlace
  module Commands
    module LibraryCommands
      # Save a playlist to the database. As a shortcut, you can pass the name
      # to save it as, instead of setting the name on the playlist and then
      # saving it.
      def save(playlist, name = nil)
        playlist.name = name if name
        library.save_playlist(playlist)
      end

      # Imports the music library from another program. Currently only iTunes is
      # supported.
      def import(from, path)
        library.import(from, path, logger: method(:puts))
      rescue Library::FileNotFoundError => e
        puts e.message
      end

      # Wipes the database. With no arguments, it just asks "Are you sure?" without
      # doing anything. To actually wipe the database, pass :yes_im_sure.
      def wipe_library(are_you_sure = :nope)
        if are_you_sure == :yes_im_sure
          library.wipe
          puts "Library wiped."
        else
          puts "Are you sure? If you are, then type: wipe_library :yes_im_sure"
        end
      end
    end
  end
end
