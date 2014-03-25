class Array
  def playlist?
    @is_playlist ||= all? { |x| x.is_a? MPD::Song }
  end

  Listlace::Selectors::STRING_SELECTORS.each do |tag|
    define_method(tag) do |*queries|
      Listlace::Selectors.string_selector(tag, self, false, *queries)
    end

    define_method("#{tag}_exact") do |*queries|
      Listlace::Selectors.string_selector(tag, self, true, *queries)
    end
  end

  Listlace::Selectors::NUMERIC_SELECTORS.each do |tag|
    define_method(tag) do |*queries|
      Listlace::Selectors.numeric_selector(tag, self, *queries)
    end
  end

  Listlace::Selectors::TIME_SELECTORS.each do |tag|
    define_method(tag) do |*queries|
      Listlace::Selectors.time_selector(tag, self, *queries)
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

