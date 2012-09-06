module Listlace
  module SinglePlayers
    class MPlayer < SinglePlayer
      def initialize
        @paused = false
        @track = nil
      end

      def active?
        not @track.nil?
      end

      def paused?
        @paused
      end

      def track
        @track
      end

      def track_title
        if active?
          if @track.respond_to? :title
            @track.title
          elsif title = metadata[:title]
            title
          else
            answer = _command("get_file_name", expect_answer: true)
            if answer && answer =~ /^ANS_FILENAME='(.+)'$/
              $1
            else
              false
            end
          end
        else
          false
        end
      end

      def play(track, &on_end)
        _quit

        track = SimpleTrack.new(track) if track.is_a? String

        if not track.respond_to? :location
          raise ArgumentError, "got a #{track.class} instead of a track"
        end

        if File.exists? track.location
          cmd = ["mplayer", "-slave", "-quiet", track.location]
          @pid, @stdin, @stdout, @stderr = Open4.popen4(*cmd)

          until @stdout.gets["playback"]
          end

          @paused = false
          @track = track

          @quit_hook_active = false
          @quit_hook = Thread.new do
            Process.wait(@pid)
            @quit_hook_active = true
            @paused = false
            @track = nil
            on_end.call
          end

          true
        else
          false
        end
      end

      def stop
        _quit
      end

      def pause
        if not @paused
          _command "pause"
        else
          false
        end
      end

      def resume
        if @paused
          _command "pause"
        else
          false
        end
      end

      def seek(where, type = :absolute)
        seconds = where.to_f / 1000
        case type
        when :absolute
          _command "seek #{seconds} 2", expect_answer: true
        when :relative
          _command "seek #{seconds} 0", expect_answer: true
        when :percent
          _command "seek #{where} 1", expect_answer: true
        else
          raise NotImplementedError
        end
      end

      def speed
        answer = _command "get_property speed", expect_answer: true
        if answer && answer =~ /^ANS_speed=([0-9.]+)$/
          $1.to_f
        else
          false
        end
      end

      def speed=(new_speed)
        answer = _command "speed_set #{new_speed.to_f}", expect_answer: true
        !!answer
      end

      def mute
        answer = _command "mute 1", expect_answer: true
        !!answer
      end

      def unmute
        answer = _command "mute 0", expect_answer: true
        !!answer
      end

      def volume
        answer = _command "get_property volume", expect_answer: true
        if answer && answer =~ /^ANS_volume=([0-9.]+)$/
          $1.to_f
        else
          false
        end
      end

      def volume=(new_volume)
        answer = _command "volume #{new_volume.to_f} 1", expect_answer: true
        !!answer
      end

      def current_time
        answer = _command "get_time_pos", expect_answer: true
        if answer && answer =~ /^ANS_TIME_POSITION=([0-9.]+)$/
          ($1.to_f * 1000).to_i
        else
          false
        end
      end

      def total_time
        answer = _command "get_time_length", expect_answer: true
        if answer && answer =~ /^ANS_LENGTH=([0-9.]+)$/
          ($1.to_f * 1000).to_i
        else
          false
        end
      end

      def metadata
        properties = %w(album artist comment genre title track year)
        properties.inject({}) do |hash, property|
          answer = _command "get_meta_#{property}", expect_answer: true
          if answer && answer =~ /^ANS_META_#{property.upcase}='(.+)'$/
            hash[property.to_sym] = $1
          else
            hash[property.to_sym] = nil
          end
          hash
        end
      end

      private

      def _command(cmd, options = {})
        if _alive? and active?
          if cmd == "pause"
            @paused = !@paused
          elsif @paused
            cmd = "pausing #{cmd}"
          end

          @stdin.puts cmd

          if options[:expect_answer]
            answer = "\n"
            answer = @stdout.gets.sub("\e[A\r\e[K", "") while answer == "\n"
            answer
          else
            true
          end
        else
          false
        end
      end

      def _quit
        if _alive?
          @quit_hook.kill unless @quit_hook_active
          _command "quit"
          @paused = false
          @track = nil
        end
        true
      end

      def _alive?
        return false if @pid.nil?
        Process.getpgid(@pid)
        true
      rescue Errno::ESRCH
        false
      end
    end
  end
end
