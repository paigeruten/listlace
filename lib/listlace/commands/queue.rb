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

  def shuffle

  end

  def sort(by = :artist_asc_album_asc_track_number_asc)

  end
end
