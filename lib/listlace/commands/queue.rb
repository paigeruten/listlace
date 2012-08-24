module Listlace
  # The queue command. Simply appends tracks to the queue. Tracks can be
  # specified by a single Track, a Playlist, an ActiveRecord::Relation, or an
  # Array containing any of the above. With or without arguments, it returns the
  # queue as an Array of Tracks, so this can be used as an accessor method.
  def q(*tracks)
    tracks.each do |playlist_or_track|
      case playlist_or_track
      when Track
        $player.queue playlist_or_track
      when Playlist
        q *playlist_or_track.tracks
      when Array
        q *playlist_or_track
      when ActiveRecord::Relation
        q *playlist_or_track.all
      end
    end
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
