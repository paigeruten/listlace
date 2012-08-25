require "plist"
require "active_support/core_ext/string"

module Listlace
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
      whitelist = Track.new.attributes.keys
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

        track = Track.new(attributes)

        if track.save
          num_tracks += 1
        end
      end
      puts "Imported #{num_tracks} tracks successfully."

      puts "Importing #{data['Playlists'].length} playlists..."
      num_playlists = 0
      data["Playlists"].each do |playlist_data|
        playlist = Playlist.new(name: playlist_data["Name"])

        if playlist.save
          playlist_data["Playlist Items"].map(&:values).flatten.each.with_index do |track_id, i|
            playlist_item = PlaylistItem.new(position: i)
            playlist_item.playlist = playlist
            if playlist_item.track = Track.where(original_id: track_id).first
              playlist_item.save!
            end
          end
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
      Database.wipe
      puts "Library wiped."
    else
      puts "Are you sure? If you are, then type: wipe_library :yes_im_sure"
    end
  end
end
