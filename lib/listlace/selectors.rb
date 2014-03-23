class Listlace
  module Selectors
    TAG_SELECTORS = %w(title artist album genre)

    TAG_SELECTORS.each do |tag|
      define_method(tag) do |what|
        case what
        when Regexp
          what = Regexp.new(what.source, Regexp::IGNORECASE) # case-insensitize
          all.select { |song| song.send(tag).to_s =~ what }
        when Symbol
          mpd.where(tag => what.to_s.tr("_", " "))
        when String
          mpd.where(tag => what)
        end
      end

      define_method("#{tag}_exact") do |what|
        mpd.where({tag => what}, {strict: true})
      end
    end

    def all
      mpd.songs
    end

    def none
      []
    end

    def search(what)
      mpd.where any: what
    end
    
    def where(params)
      mpd.where(params)
    end

    def where_exact(params)
      mpd.where(params, {strict: true})
    end
  end
end

