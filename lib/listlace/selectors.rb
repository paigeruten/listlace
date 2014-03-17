class Listlace
  module Selectors
    TAG_SELECTORS = %w(title artist album)

    TAG_SELECTORS.each do |tag|
      define_method(tag) do |what|
        mpd.where(tag => what)
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

