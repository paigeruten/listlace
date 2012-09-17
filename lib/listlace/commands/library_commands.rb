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

      def like
        if player.current_track.respond_to?(:rating)
          player.current_track.increment! :rating
        end
      end

      def dislike
        if player.current_track.respond_to?(:rating)
          player.current_track.decrement! :rating
        end
      end

      def add(path, options = {})
        if File.directory?(path)
          extensions = {}
          Array(options.delete(:extensions)).each do |ext|
            extensions[ext.to_s] = true
          end

          num_tracks = 0
          Dir[File.join(path, "**", "*")].each do |file|
            unless File.directory?(file)
              ext = File.extname(file).sub(/^\./, "")
              if extensions[ext].nil?
                print "Do you want to add files with the '.#{ext}' extension [y/N]? "
                if gets[0].downcase == "y"
                  extensions[ext] = true
                else
                  extensions[ext] = false
                end
              end

              if extensions[ext]
                if library.add_track(file, options)
                  num_tracks += 1
                end
              end
            end
          end

          if num_tracks == 0
            puts "Can't find any audio files there. Perhaps they are already added?"
          elsif num_tracks == 1
            puts "1 track added."
          else
            puts "#{num_tracks} tracks added."
          end
        else
          if library.add_track(path, options)
            puts "1 track added."
          else
            puts "Track couldn't be added. Perhaps it's not an audio file?"
          end
        end
      rescue Library::FileNotFoundError => e
        puts e.message
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
