class Array
  def playlist?
    @is_playlist ||= all? { |x| x.is_a? MPD::Song }
  end

  Listlace::Selectors::STRING_SELECTORS.each do |tag|
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

  Listlace::Selectors::NUMERIC_SELECTORS.each do |tag|
    define_method(tag) do |*queries|
      queries.map do |query|
        case query
        when Numeric
          self.select { |song| song.send(tag) == query }
        when Hash
          query.map do |op, value|
            op = { eq: "==", ne: "!=", lt: "<", le: "<=", gt: ">", ge: ">=" }[op] || op
            self.select { |song| song.send(tag).to_i.send(op, value) }
          end.inject(:&)
        when Range
          self.select { |song| query === song.send(tag) }
        end
      end.inject(&:|)
    end
  end

  alias year date
  
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

