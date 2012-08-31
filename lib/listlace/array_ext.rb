class Array
  attr_accessor :name

  def playlist?
    if @name || all? { |x| x.is_a? Listlace::Track }
      @name ||= ""
      true
    else
      false
    end
  end

  def shuffle_except(elem)
    ary = dup
    dup.shuffle_except! elem
    dup
  end

  def shuffle_except!(elem)
    replace([elem] + (self - [elem]).shuffle)
  end

  alias _original_to_s to_s
  def to_s
    if playlist?
      "%s (%d track%s)" % [@name || "playlist", length, ("s" if length != 1)]
    else
      _original_to_s
    end
  end

  alias _original_inspect inspect
  def inspect
    playlist? ? to_s : _original_inspect
  end

  alias _original_pretty_inspect pretty_inspect
  def pretty_inspect
    playlist? ? inspect : _original_pretty_inspect
  end
end
