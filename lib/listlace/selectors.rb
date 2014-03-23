class Listlace
  module Selectors
    STRING_SELECTORS = %w(title artist album genre)
    NUMERIC_SELECTORS = %w(track date disc time)

    STRING_SELECTORS.each do |tag|
      define_method(tag) do |*queries|
        all.send(tag, *queries)
      end

      define_method("#{tag}_exact") do |*queries|
        all.send("#{tag}_exact", *queries)
      end
    end

    NUMERIC_SELECTORS.each do |tag|
      define_method(tag) do |*queries|
        all.send(tag, *queries)
      end
    end

    alias year date

    def all
      @all ||= mpd.songs
    end

    def none
      []
    end
  end
end

