module Listlace
  # This is the music box. It contains a queue, which is an array of tracks. It
  # then plays these tracks sequentially. The buttons for play, pause, next,
  # previous, etc. are all located here.
  class Player
    attr_accessor :current_track

    def initialize
      @mplayer = nil
      @queue = []
      @current_track = nil
      @current_track_index = nil
      @paused = false
      @started = false
    end

    def queue(track = nil)
      @queue << track if track.is_a? Track
      @queue.dup
    end

    def clear
      stop
      @queue = []
    end

    def empty?
      @queue.empty?
    end

    def paused?
      @paused
    end

    def started?
      @started
    end

    def start
      unless empty?
        @started = true
        @current_track = @queue.first
        @current_track_index = 0
        load_track(@current_track)
      end
    end

    def stop
      @mplayer.quit if @mplayer
      @mplayer = nil
      @current_track = nil
      @current_track_index = nil
      @paused = false
      @started = false
    end

    def pause
      if not paused?
        @paused = true
        @mplayer.command "pause"
      end
    end

    def resume
      if paused?
        @paused = false
        if @mplayer && @mplayer.alive?
          @mplayer.command "pause"
        else
          load_track @current_track
        end
      end
    end

    def restart
      change_track(0)
    end

    def back
      change_track(-1)
    end

    def skip
      change_track(1)
    end

    def current_time
      answer = @mplayer.command "get_time_pos", expect_answer: true
      if answer =~ /^ANS_TIME_POSITION=([0-9.]+)$/
        ($1.to_f * 1000).to_i
      else
        0
      end
    end

    def formatted_current_time
      Track.format_time(current_time)
    end

    private

    def change_track(by = 1)
      @current_track_index += by
      @current_track = @queue[@current_track_index]
      if @current_track && @current_track_index >= 0
        if paused?
          @mplayer.quit if @mplayer
        else
          load_track(@current_track)
        end
        true
      else
        stop
        false
      end
    end

    def load_track(track)
      @mplayer.quit if @mplayer
      @mplayer = MPlayer.new(track) { send :change_track }
      @paused = false
    end
  end
end
