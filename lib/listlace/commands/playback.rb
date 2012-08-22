module Listlace
  def play
    if $player.queue.empty?
      puts "Nothing to play."
    else
      $player.start
      track = $player.current_track
      puts "Now Playing: #{track.artist} - #{track.name} (0:00 / #{track.formatted_total_time})"
    end
  end

  def stop
    $player.stop
  end
end
