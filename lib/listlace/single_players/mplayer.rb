module Listlace
  module SinglePlayers
    class MPlayer < SinglePlayer
      def initialize
        @active = false
        @paused = false
      end

      def active?
        @active
      end

      def paused?
        @paused
      end

      def play(track, &on_end)
        _quit

        if File.exists? track.location
          cmd = ["mplayer", "-slave", "-quiet", track.location]
          @pid, @stdin, @stdout, @stderr = Open4.popen4(*cmd)

          until @stdout.gets["playback"]
          end

          @active = true
          @paused = false

          @quit_hook_active = false
          @quit_hook = Thread.new do
            Process.wait(@pid)
            @quit_hook_active = true
            @active = false
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

      def speed(new_speed = nil)
        if new_speed
          answer = _command "speed_set #{new_speed.to_f}", expect_answer: true
          !!answer
        else
          answer = _command "get_property speed", expect_answer: true
          if answer && answer =~ /^ANS_speed=([0-9.]+)$/
            $1.to_f
          else
            false
          end
        end
      end

      def current_time
        answer = _command "get_time_pos", expect_answer: true
        if answer && answer =~ /^ANS_TIME_POSITION=([0-9.]+)$/
          ($1.to_f * 1000).to_i
        else
          false
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
          @active = false
          @paused = false
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
