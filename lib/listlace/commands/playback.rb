module Listlace
  $player = nil
  $playing = false
  $playlist = []

  def play
    if $playlist.empty?
      puts "Nothing to play."
    else
      stop if $playing
      track = $playlist.first
      $playing = true
      $player = MPlayer::Slave.new track.path
      puts "Now Playing: #{track.artist} - #{track.name} (0:00 / #{track.formatted_total_time})"
    end
  end

  def stop
    if $playing
      $player.quit if $player
      $player = nil
      $playing = false
    end
  end
end
