module Listlace
  # The queue command. Simply appends tracks to the queue. It creates a playlist
  # with the arguments you give it, so anything you can pass to the playlist()
  # method you can pass to this. It returns the queue, so you can use this
  # method as an accessor by not passing any arguments.
  def q(*args)
    $player.queue playlist(*args)
    $player.queue
  end

  # Clears the queue.
  def clear
    $player.clear
    puts "Queue cleared."
  end

  # Shuffles the queue, keeping the current track at the top.
  def shuffle
    $player.shuffle
    puts "Shuffled."
  end

  # Sorts the queue by a list of fields and directions in the form of a symbol,
  # or uses the proc given to it, which should take two Tracks and return -1, 0,
  # or 1.
  def sort(by = :artist_asc_album_asc_track_number_asc, &proc)
    if proc
      $player.sort(&proc)
    else
      $player.sort do |a, b|
        result = 0
        by.to_s.scan(/([a-z_]+?)_(asc|desc)(?:_|$)/).each do |column, direction|
          a_value = a.send(column)
          b_value = b.send(column)
          a_value = a_value.downcase if a_value.respond_to? :downcase
          b_value = b_value.downcase if b_value.respond_to? :downcase
          dir = (direction == "desc") ? -1 : 1
          if a_value != b_value
            if a_value.nil? || b_value.nil?
              result = dir
            else
              result = (a_value <=> b_value) * dir
            end
            break
          end
        end
        result
      end
    end
  end
end
