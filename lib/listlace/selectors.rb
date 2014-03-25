class Listlace
  module Selectors
    STRING_SELECTORS = %w(title artist album genre)
    NUMERIC_SELECTORS = %w(track date disc)
    TIME_SELECTORS = %w(time)

    (STRING_SELECTORS | NUMERIC_SELECTORS | TIME_SELECTORS).each do |tag|
      define_method(tag) do |*queries|
        all.send(tag, *queries)
      end

      if STRING_SELECTORS.include? tag
        define_method("#{tag}_exact") do |*queries|
          all.send("#{tag}_exact", *queries)
        end
      end
    end

    alias year date

    def all
      @all ||= mpd.songs
    end

    def none
      []
    end

    def self.string_selector(tag, playlist, exact, *queries)
      if exact
        playlist.select { |song| song.send(tag).to_s == query.to_s }
      else
        queries.map do |query|
          case query
          when Regexp
            query = Regexp.new(query.source, Regexp::IGNORECASE) # case-insensitize
            playlist.select { |song| song.send(tag).to_s =~ query }
          when Symbol
            playlist.select { |song| song.send(tag).to_s.downcase[query.to_s.downcase.tr("_", " ")] }
          when String
            playlist.select { |song| song.send(tag).to_s.downcase[query.downcase] }
          end
        end.inject(:|)
      end
    end

    def self.numeric_selector(tag, playlist, *queries)
      queries.map do |query|
        case query
        when Numeric
          playlist.select { |song| song.send(tag) == query }
        when Hash
          query.map do |op, value|
            op = { eq: "==", ne: "!=", lt: "<", le: "<=", gt: ">", ge: ">=" }[op] || op
            playlist.select { |song| song.send(tag).to_i.send(op, value) }
          end.inject(:&)
        when Range
          playlist.select { |song| query === song.send(tag) }
        end
      end.inject(:|)
    end

    def self.time_selector(tag, playlist, *queries)
      queries.map! do |query|
        case query
        when String
          TimeHelpers.parse_time(query)
        when Range
          Range.new(
            TimeHelpers.parse_time(query.begin.to_s),
            TimeHelpers.parse_time(query.end.to_s),
            query.exclude_end?
          )
        when Hash
          query.each do |op, value|
            if value.is_a? String
              query[op] = TimeHelpers.parse_time(value)
            end
          end
          query
        else
          query
        end
      end

      numeric_selector(tag, playlist, *queries)
    end
  end
end

