module Listlace
  STRING_SELECTORS = %w(name artist composer album album_artist genre comments location)
  INTEGER_SELECTORS = %w(disc_number disc_count track_number track_count year bit_rate sample_rate play_count skip_count rating)

  STRING_SELECTORS.each do |column|
    define_method(column) do |*args|
      options = args.last.is_a?(Hash) ? args.pop : {}

      playlists = args.map { |query| string_selector(column, query, options) }
      playlist *playlists
    end
  end

  INTEGER_SELECTORS.each do |column|
    define_method(column) do |*args|
      playlists = args.map { |arg| integer_selector(column, arg) }
      playlist *playlists
    end
  end

  # rename the "name" selector to "song"
  alias_method :song, :name
  remove_method :name

  # The length selector is an integer selector for the length of a track. A
  # plain integer given to it represents the number of seconds. It can also take
  # a String in the format "1:23", to represent 83 seconds, for example. These
  # can be part of a Range, as usual: "1:23".."2:05", for example.
  def length(*args)
    normalize = lambda do |value|
      case value
      when String
        Track.parse_time(value)
      when Integer
        value * 1000
      when Range
        (normalize.(value.begin))..(normalize.(value.end))
      end
    end

    playlists = args.map do |arg|
      if arg.is_a? Hash
        key = arg.keys.first
        arg[key] = normalize.(arg[key])
      else
        arg = normalize.(arg)
      end

      # If they want tracks of length "0:05", for example, we need to look for
      # tracks that are from 5000 to 5999 milliseconds long.
      if arg.is_a? Integer
        arg = (arg)..(arg + 999)
      end

      integer_selector(:total_time, arg)
    end

    playlist *playlists
  end

  # Makes a playlist out of tracks that match the string query on the given
  # column. It's SQL underneath, so you can use % and _ as wildcards in the
  # query. By default, % wildcards are inserted on the left and right of your
  # query. Use the :match option to change this:
  #
  #   :match => :middle   "%query%"   (default)
  #   :match => :left     "query%"
  #   :match => :right    "%query"
  #   :match => :exact    "query"
  #
  # This method shouldn't have to be used directly. Many convenient methods are
  # generated for you, one for each string field you may want to select on.
  # These are: artist, composer, album, album_artist, genre, comments, location.
  # For example:
  #
  #   artist :muse, match: :exact #=> playlist (108 tracks)
  #   composer :rachmanino #=> playlist (33 tracks)
  #
  # To match the name of a track, use song:
  #
  #   song "frontier psychiatrist" #=> playlist (1 track)
  #
  def string_selector(column, query, options = {})
    options[:match] ||= :middle

    query = {
      exact: "#{query}",
      left: "#{query}%",
      right: "%#{query}",
      middle: "%#{query}%"
    }[options[:match]]

    tracks = Track.arel_table
    PlaylistArray.new(Track.where(tracks[column].matches(query)).all)
  end

  # Makes a playlist out of tracks that satisfy certain conditions on the given
  # integer column. You can pass an exact value to check for equality, a range,
  # or a hash that specifies greater-than and less-than options like this:
  #
  #   integer_selector :year, greater_than: 2000 #=> playlist (3555 tracks)
  #
  # The possible operators, with their shortcuts, are:
  #
  #   :greater_than / :gt
  #   :less_than / :lt
  #   :greater_than_or_equal / :gte
  #   :less_than_or_equal / :lte
  #   :not_equal / :ne
  #
  # Note: You can only use one of these operators at a time. If you want a
  # range, use a Range.
  #
  # This method shouldn't have to be used directly. Many convenient methods are
  # generated for you, one for each integer field you may want to select on.
  # These are: disc_number, disc_count, track_number, track_count, year,
  # bit_rate, sample_rate, play_count, skip_count, rating, length. Length is
  # special, it can take any of the time formats that the seek command can. For
  # example:
  #
  #   year 2010..2012 #=> playlist (1060 tracks)
  #   length gt: "4:00" #=> playlist (2543 tracks)
  #
  def integer_selector(column, value_or_options)
    if value_or_options.is_a? Hash
      operator = {
        greater_than: ">",
        gt: ">",
        less_than: "<",
        lt: "<",
        greater_than_or_equal: ">=",
        gte: ">=",
        less_than_or_equal: "<=",
        lte: "<=",
        not_equal: "<>",
        ne: "<>"
      }[value_or_options.keys.first]
      tracks = Track.where("tracks.#{column} #{operator} ?", value_or_options.values.first)
      PlaylistArray.new(tracks.all)
    else
      tracks = Track.arel_table
      PlaylistArray.new(Track.where(column => value_or_options).all)
    end
  end

  # Creates or looks up a playlist. You can pass any number of multiple types of
  # objects to make a playlist:
  #
  #   Track: Makes a playlist with one track
  #   ActiveRecord::Relation: Makes a playlist out of the resulting Track or Playlist records
  #   Symbol or String: Tries to retrieve a saved playlist with the given name.
  #     If it can't find one, it creates a new one.
  #
  # You can also pass in the results of a selector. In this way you can create a
  # playlist out of many smaller pieces.
  #
  # If given no arguments, it returns a blank playlist.
  #
  def playlist(*args)
    args.map do |object|
      case object
      when Track
        PlaylistArray.new([object])
      when Playlist
        PlaylistArray.new([object.tracks.all], object.name)
      when PlaylistArray
        object
      when Array
        playlist *object
      when ActiveRecord::Relation
        if object.table.name == "tracks"
          PlaylistArray.new([object.all])
        elsif object.table.name == "playlists"
          playlist *object.all
        end
      when Symbol, String
        playlists = Playlist.arel_table
        if playlist = Playlist.where(playlists[:name].matches(object.to_s)).first
          PlaylistArray.new(playlist)
        else
          PlaylistArray.new([], object)
        end
      end
    end.inject(:+)
  end
end
