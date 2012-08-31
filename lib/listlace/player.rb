require "listlace/player/mplayer"

module Listlace
  # This is the music box. It contains a queue, which is an array of tracks. It
  # then plays these tracks sequentially. The buttons for play, pause, next,
  # previous, etc. are all located here.
  class Player
    attr_reader :current_track, :current_track_index, :repeat_mode

    def initialize
      @mplayer = nil
      @queue = []
      @queue.name = :queue
      @current_track = nil
      @current_track_index = nil
      @paused = false
      @started = false
      @repeat_mode = false
    end

    def queue(playlist = nil)
      if playlist.is_a? Array
        if @queue.empty? && playlist.name && !playlist.name.empty?
          @queue = playlist.dup
        else
          @queue += playlist
          @queue.name = :queue
        end
      end
      @queue.dup
    end

    def clear
      stop
      @queue.clear
      @queue.name = :queue
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

    def repeat(one_or_all_or_off)
      case one_or_all_or_off
      when :one
        @repeat_mode = :one
      when :all
        @repeat_mode = :all
      when :off
        @repeat_mode = false
      end
    end

    def restart
      change_track(0)
    end

    def back(n = 1)
      change_track(-n)
    end

    def skip(n = 1)
      @current_track.increment! :skip_count
      @current_track.update_column :skip_date, Time.now
      change_track(n)
    end

    def seek(where)
      case where
      when Integer
        @mplayer.command("seek %d 0" % [where], expect_answer: true)
      when Range
        @mplayer.command("seek %d 2" % [where.begin * 60 + where.end], expect_answer: true)
      when String
        @mplayer.command("seek %d 2" % [Track.parse_time(where) / 1000], expect_answer: true)
      when Hash
        if where[:abs]
          if where[:abs].is_a? Integer
            @mplayer.command("seek %d 2" % [where[:abs]], expect_answer: true)
          else
            seek(where[:abs])
          end
        elsif where[:percent]
          @mplayer.command("seek %d 1" % [where[:percent]], expect_answer: true)
        end
      end
    end

    def speed
      answer = @mplayer.command("get_property speed", expect_answer: true)
      if answer =~ /^ANS_speed=([0-9.]+)$/
        $1.to_f
      end
    end

    def set_speed(speed)
      @mplayer.command("speed_set %f" % [speed], expect_answer: true)
    end

    def shuffle
      if started?
        @queue.shuffle_except! @current_track
        @current_track_index = 0
      else
        @queue.shuffle!
      end
    end

    def sort(&by)
      @queue.sort! &by

      if started?
        @current_track_index = @queue.index(@current_track)
      end
    end

    def current_time
      answer = @mplayer.command "get_time_pos", expect_answer: true
      if answer =~ /^ANS_TIME_POSITION=([0-9.]+)$/
        ($1.to_f * 1000).to_i
      end
    end

    def formatted_current_time
      Track.format_time(current_time)
    end

    private

    def change_track(by = 1, options = {})
      if options[:auto]
        @current_track.increment! :play_count
        @current_track.update_column :play_date_utc, Time.now
      end
      @current_track_index += by
      if options[:auto] && @repeat_mode
        case @repeat_mode
        when :one
          @current_track_index -= by
        when :all
          if @current_track_index >= @queue.length
            @current_track_index = 0
          end
        end
      end
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
      @mplayer = MPlayer.new(track) { send(:change_track, 1, auto: true) }
      @paused = false
    end
  end
end
