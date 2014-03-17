class Array
  def playlist?
    @is_playlist ||= all? { |x| x.is_a? MPD::Song }
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

