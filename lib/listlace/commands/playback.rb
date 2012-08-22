module Listlace
  $afplay_pid = nil
  $playing = false
  $playlist = []

  def play
    if $playlist.empty?
      puts "Nothing to play."
    else
      stop if $playing
      track = $playlist.first
      $playing = true
      $afplay_pid = Process.spawn("afplay", track.path)
      Process.detach $afplay_pid
      puts "Now Playing: #{track.artist} - #{track.name} (0:00 / #{track.formatted_total_time})"
    end
  end

  def stop
    if $playing
      Process.kill("QUIT", $afplay_pid)
      $playing = false
      $afplay_pid = nil
    end
  end
end
