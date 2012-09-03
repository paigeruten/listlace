module Listlace
  class Library
    class FileNotFoundError < ArgumentError; end

    def initialize(options = {})
      options[:db_path] ||= "library"
      options[:db_adapter] ||= "sqlite3"

      unless File.exists? Listlace::DIR
        FileUtils.mkdir_p Listlace::DIR
      end

      @db_path = options[:db_path]
      @db_path = "#{Listlace::DIR}/#{@db_path}" unless @db_path.include? "/"
      @db_path = "#{@db_path}.sqlite3" unless @db_path =~ /\.sqlite3$/

      @db_adapter = options[:db_adapter]

      Database.disconnect if Database.connected?
      Database.connect(@db_adapter, @db_path)
      Database.generate_schema unless Database.exists?(@db_path)
    end

    def tracks
      Track.scoped
    end

    def playlists
      Playlist.scoped
    end

    def size
      tracks.length
    end

    def wipe
      Database.wipe(@db_adapter, @db_path)
    end

    def save_playlist(playlist)
      playlist_table = playlists.arel_table
      if model = playlists.where(playlist_table[:name].matches(playlist.name)).first
        model.playlist_items.destroy_all
      else
        model = playlists.new(name: playlist.name)
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

    def import(from, path, options = {})
      logger = options[:logger]
      if not File.exists?(path)
        raise FileNotFoundError, "File '%s' doesn't exist." % [path]
      elsif from == :itunes
        logger.("Parsing XML...") if logger
        data = Plist::parse_xml(path)

        logger.("Importing #{data['Tracks'].length} tracks...") if logger
        num_tracks = 0
        whitelist = tracks.new.attributes.keys
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

          track = tracks.new(attributes)

          if track.kind =~ /audio/
            if track.save
              num_tracks += 1
            end
          else
            logger.("[skipping non-audio file]") if logger
          end
        end
        logger.("Imported #{num_tracks} tracks successfully.") if logger

        logger.("Importing #{data['Playlists'].length} playlists...") if logger
        num_playlists = 0
        data["Playlists"].each do |playlist_data|
          playlist = []
          playlist.name = playlist_data["Name"]

          if ["Library", "Music", "Movies", "TV Shows", "iTunes DJ"].include? playlist.name
            logger.("[skipping \"#{playlist.name}\" playlist]") if logger
          else
            playlist_data["Playlist Items"].map(&:values).flatten.each do |original_id|
              playlist << tracks.where(original_id: original_id).first
            end
            playlist.compact!
            save_playlist playlist
            num_playlists += 1
          end
        end
        logger.("Imported #{num_playlists} playlists successfully.") if logger
      end
    end
  end
end
