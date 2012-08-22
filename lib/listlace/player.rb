module Listlace
  class Player
    attr_accessor :mplayer, :queue, :current_track

    def initialize
      @mplayer = nil
      @queue = []
      @current_track = nil
      @current_track_index = nil
    end

    def start
      unless @queue.empty?
        @current_track = @queue.first
        @current_track_index = 0
        _play @current_track
      end
    end

    def next
      @current_track_index += 1
      @current_track = @queue[@current_track_index]
      if @current_track
        _play @current_track
      else
        stop
      end
    end

    def stop
      @mplayer.quit if _mplayer_alive?
      @mplayer = nil
      @current_track = nil
      @current_track_index = nil
    end

    private

    def _play(track)
      @mplayer.quit if _mplayer_alive?
      @mplayer = MPlayer::Slave.new track.path

      Thread.new do
        Process.wait(@mplayer.pid)
        $player.next
      end
    end

    def _mplayer_alive?
      if @mplayer
        begin
          Process.getpgid(@mplayer.pid)
          true
        rescue Errno::ESRCH
          false
        end
      end
    end
  end
end
