class Listlace
  module Selectors
    TAG_SELECTORS = %w(title artist album genre)

    TAG_SELECTORS.each do |tag|
      define_method(tag) do |*queries|
        all.send(tag, *queries)
      end

      define_method("#{tag}_exact") do |*queries|
        all.send("#{tag}_exact", *queries)
      end
    end

    def all
      @all ||= mpd.songs
    end

    def none
      []
    end
  end
end

