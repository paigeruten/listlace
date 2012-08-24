module Listlace
  # The play command. With no arguments, it either resumes playback or starts
  # playing the queue. With arguments, it replaces the queue with the given
  # tracks and starts playing.
  def p(*tracks)
    if tracks.empty?
      if $player.paused?
        $player.resume
        status :playing
      elsif $player.started?
        $player.pause
        status :playing
      else
        if $player.empty?
          puts "Nothing to play."
        else
          $player.start
          track = $player.current_track
          status :playing
        end
      end
    else
      stop
      clear
      q *tracks
      p
    end
  end

  # Stops playback. The queue is still intact, but goes back to the beginning
  # when playback is started again.
  def stop
    $player.stop
    puts "Stopped."
  end

  # Start the current track from the beginning.
  def restart
    $player.restart
    status :playing
  end

  # Go back one song in the queue.
  def back
    if $player.back
      status :playing
    else
      puts "End of queue."
    end
  end

  # Go directly to the next song in the queue.
  def skip
    if $player.skip
      status :playing
    else
      puts "End of queue."
    end
  end

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

  def status(type = [:playlist, :playing])
    case type
    when Array
      type.each { |t| status t }
    when :playlist
      #nop
    when :playing
      if $player.started?
        s = $player.paused? ? "Paused" : "Now Playing"
        name = $player.current_track.name
        artist = $player.current_track.artist
        time = $player.formatted_current_time
        total_time = $player.current_track.formatted_total_time
        puts "%s: %s - %s (%s / %s)" % [s, name, artist, time, total_time]
      else
        puts "Stopped."
      end
    end
  end
end
