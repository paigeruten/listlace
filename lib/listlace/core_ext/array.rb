class Array
  def playlist?
    @is_playlist ||= all? { |x| x.is_a? MPD::Song }
  end

  Listlace::Selectors::TAG_SELECTORS.each do |tag|
    define_method(tag) do |*queries|
      queries.map do |query|
        case query
        when Regexp
          query = Regexp.new(query.source, Regexp::IGNORECASE) # case-insensitize
          self.select { |song| song.send(tag).to_s =~ query }
        when Symbol
          self.select { |song| song.send(tag).to_s.downcase[query.to_s.tr("_", " ")] }
        when String
          self.select { |song| song.send(tag).to_s.downcase == query }
        end
      end.inject(:|)
    end

    define_method("#{tag}_exact") do |*queries|
      queries.map do |query|
        self.select { |song| song.send(tag).to_s == query.to_s }
      end
    end
  end
  
  alias _original_inspect inspect
  def inspect
    if playlist?
      plural = (length == 1) ? "" : "s"
      "[#{length} song#{plural}]"
    else
      _original_inspect
    end
  end

  alias _original_pretty_inspect pretty_inspect
  def pretty_inspect
    if playlist?
      inspect
    else
      _original_pretty_inspect
    end
  end
end

