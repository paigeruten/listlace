module Listlace
  # This is the music box. It plays playlists. It contains a queue, which is
  # just a playlist. To tell it what to play, you add one or more playlists to
  # the queue, then start playing using the start method.
  #
  # Playback commands like pause, resume, seek, and so on are delegated to the
  # SinglePlayer, which takes care of playing each individual song.
  #
  # Each method that performs an action is like a button on a physical media
  # player: you can press the buttons even if they aren't applicable to the
  # current state of the player. If that's the case, the methods wil return
  # false. Otherwise, they'll return a truthy value.
  class Player
    DEFAULT_SINGLE_PLAYER = SinglePlayers::MPlayer

    attr_reader :current_track, :current_track_index, :repeat_mode

    def initialize
      @single_player = DEFAULT_SINGLE_PLAYER.new
      @queue = []
      @current_track = nil
      @current_track_index = nil
      @playlist_paused = false
      @started = false
      @repeat_mode = false
    end

    def queue(playlist = nil)
      if playlist.is_a? Array
        playlist = playlist.dup
        playlist.map! { |track| track.is_a?(String) ? SimpleTrack.new(track) : track }
        playlist.select! { |track| track.respond_to? :location }
        if @queue.empty?
          @queue = playlist
        else
          @queue += playlist
        end
      end
      @queue.dup
    end

    def clear
      stop
      @queue.clear
      true
    end

    def empty?
      @queue.empty?
    end

    def playlist_paused?
      @playlist_paused
    end

    def paused?
      playlist_paused? or @single_player.paused?
    end

    def started?
      @started
    end

    def start
      unless empty?
        @started = true
        @playlist_paused = false
        @current_track = @queue.first
        @current_track_index = 0
        play_track @current_track
        true
      else
        false
      end
    end

    def stop
      @single_player.stop
      @current_track = nil
      @current_track_index = nil
      @playlist_paused = false
      @started = false
      true
    end

    def pause
      @single_player.pause
    end

    def resume
      if playlist_paused?
        play_track @current_track
        @playlist_paused = false
        true
      else
        @single_player.resume
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
      true
    end

    def restart
      change_track(0)
    end

    def back(n = 1)
      change_track(-n)
    end

    def skip(n = 1)
      if @current_track.respond_to?(:increment_skip_count)
        @current_track.increment_skip_count
      end
      change_track(n)
    end

    def seek(where)
      if playlist_paused?
        resume
        pause
        seek where
      else
        case where
        when Integer
          @single_player.seek(where, :relative)
        when Range
          seconds = where.begin * 60 + where.end
          @single_player.seek(seconds * 1000, :absolute)
        when String
          @single_player.seek(Listlace.parse_time(where), :absolute)
        when Hash
          if where[:abs]
            if where[:abs].is_a? Integer
              @single_player.seek(where[:abs], :absolute)
            else
              seek(where[:abs])
            end
          elsif where[:percent]
            @single_player.seek(where[:percent], :percent)
          end
        end
      end
    end

    def speed
      @single_player.active? ? @single_player.speed : 1.0
    end

    def speed=(new_speed)
      @single_player.speed(new_speed)
    end

    def shuffle
      if started?
        @queue.shuffle_except! @current_track
        @current_track_index = 0
      else
        @queue.shuffle!
      end
      true
    end

    def sort(&by)
      @queue.sort! &by
      if started?
        @current_track_index = @queue.index(@current_track)
      end
      true
    end

    def current_time
      @single_player.active? ? @single_player.current_time : 0
    end

    private

    def change_track(by = 1, options = {})
      if started?
        if options[:auto] && @current_track.respond_to?(:increment_play_count)
          @current_track.increment_play_count
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
          if @single_player.paused?
            @single_player.stop
            @playlist_paused = true
          elsif not playlist_paused?
            play_track @current_track
          end
        else
          stop
        end
        true
      else
        false
      end
    end

    def play_track(track)
      @single_player.play(track) do
        change_track(1, auto: true)
        ActiveRecord::Base.connection.close if defined?(ActiveRecord)
      end
      @playlist_paused = false
      true
    end
  end
end
