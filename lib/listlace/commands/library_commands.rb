module Listlace
  module Commands
    module LibraryCommands
      def save(playlist, name = nil)
        playlist.name = name if name
        if model = library.playlists.where(name: playlist.name).first
          model.playlist_items.destroy_all
        else
          model = library.playlists.new(name: playlist.name)
          model.save!
        end

        playlist.each.with_index do |track, i|
          item = PlaylistItem.new(position: i)
          item.playlist = model
          item.track = track
          item.save!
        end
        playlist
      end

      # Imports the music library from another program. Currently only iTunes is
      # supported.
      def import(from, path)
        if not File.exists?(path)
          puts "File '%s' doesn't exist." % [path]
        elsif from == :itunes
          puts "Parsing XML..."
          data = Plist::parse_xml(path)

          puts "Importing #{data['Tracks'].length} tracks..."
          num_tracks = 0
          whitelist = library.tracks.new.attributes.keys
          data["Tracks"].each do |track_id, row|
            # row already contains a hash of attributes almost ready to be passed to
            # ActiveRecord. We just need to modify the keys, e.g. change "Play Count"
            # to "play_count".
            attributes = row.inject({}) do |acc, (key, value)|
              attribute = key.gsub(" ", "").underscore
              attribute = "original_id" if attribute == "track_id"
              acc[attribute] = value if whitelist.include? attribute
              acc
            end

            # change iTunes' URL-style locations into simple paths
            if attributes["location"] && attributes["location"] =~ /^file:\/\//
              attributes["location"].sub! /^file:\/\/localhost/, ""

              # CGI::unescape changes plus signs to spaces. This is a work around to
              # keep the plus signs.
              attributes["location"].gsub! "+", "%2B"

              attributes["location"] = CGI::unescape(attributes["location"])
            end

            track = library.tracks.new(attributes)

            if track.kind =~ /audio/
              if track.save
                num_tracks += 1
              end
            else
              puts "[skipping non-audio file]"
            end
          end
          puts "Imported #{num_tracks} tracks successfully."

          puts "Importing #{data['Playlists'].length} playlists..."
          num_playlists = 0
          data["Playlists"].each do |playlist_data|
            playlist = []
            playlist.name = playlist_data["Name"]

            if ["Library", "Music", "Movies", "TV Shows", "iTunes DJ"].include? playlist.name
              puts "[skipping \"#{playlist.name}\" playlist]"
            else
              playlist_data["Playlist Items"].map(&:values).flatten.each do |original_id|
                playlist << library.tracks.where(original_id: original_id).first
              end
              playlist.compact!
              save playlist
              num_playlists += 1
            end
          end
          puts "Imported #{num_playlists} playlists successfully."
        end
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
