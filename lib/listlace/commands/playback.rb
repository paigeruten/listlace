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
        if $player.speed == 1
          $player.pause
          status :playing
        else
          $player.set_speed 1
          puts "Back to normal."
        end
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

  # Seek to a particular position in the current track. If given an integer, it
  # will seek that many seconds forward or backward. If given a Range, it will
  # seek to that specific time, the first number in the Range representing the
  # minutes, the second number representing the seconds. You can also pass a
  # String like "1:23:45" to do the same thing. To seek to an absolute time in
  # seconds, do it like "seek(abs: 40)". To seek to a percentage, do something
  # like "seek(percent: 75)".
  def seek(where)
    $player.seek(where)
    status :playing
  end

  def ff(speed = 2)
    $player.set_speed(speed)
    puts "Fast-forwarding. (x#{speed})"
  end

  def repeat(one_or_all = :all)

  end

  def norepeat
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
