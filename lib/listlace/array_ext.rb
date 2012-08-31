class Array
  attr_accessor :name

  # Check if this array is a playlist. It's a playlist if it has
  # a name attribute set or consists entirely of Track instances.
  def playlist?
    if @name || all? { |x| x.is_a? Listlace::Track }
      @name ||= ""
      true
    else
      false
    end
  end

  # Returns a new array that is shuffled, but with elem at the top.
  # This is how playlists that are currently playing are shuffled.
  # The currently playing track goes to the top, the rest of the
  # tracks are shuffled.
  def shuffle_except(elem)
    ary = dup
    dup.shuffle_except! elem
    dup
  end

  # Like shuffle_except, but shuffles in-place.
  def shuffle_except!(elem)
    if i = index(elem)
      delete_at(i)
      shuffle!
      unshift(elem)
    else
      shuffle!
    end
  end

  # Override to_s to check if the array is a playlist, and format
  # it accordingly.
  alias _original_to_s to_s
  def to_s
    if playlist?
      "%s (%d track%s)" % [@name || "playlist", length, ("s" if length != 1)]
    else
      _original_to_s
    end
  end

  # Override inspect for nice pry output.
  alias _original_inspect inspect
  def inspect
    playlist? ? to_s : _original_inspect
  end

  # Override pretty_inspect for nice pry output.
  alias _original_pretty_inspect pretty_inspect
  def pretty_inspect
    playlist? ? inspect : _original_pretty_inspect
  end
end
