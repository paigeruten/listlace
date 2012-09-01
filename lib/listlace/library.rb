module Listlace
  class Library
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
  end
end
