require "plist"
require "active_support/core_ext/string"

module Listlace
  def import_from_itunes(path_to_xml)
    data = Plist::parse_xml(path_to_xml)

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

      track = Track.new(attributes)
      track.save!
    end

    data["Playlists"].each do |playlist_data|
      playlist = Playlist.new(name: playlist_data["Name"])
      playlist.save!

      playlist_data["Playlist Items"].map(&:values).flatten.each.with_index do |track_id, i|
        playlist_item = PlaylistItem.new(position: i)
        playlist_item.playlist = playlist
        if playlist_item.track = Track.where(original_id: track_id).first
          playlist_item.save!
        end
      end
    end
  end
end
