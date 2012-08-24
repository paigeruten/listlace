module Listlace
  # This is a simple MPlayer wrapper, it just handles opening the MPlayer
  # process, hooking into when mplayer exits (when the song is done), and
  # issuing commands through the slave protocol.
  class MPlayer
    def initialize(track, &on_quit)
      cmd = "/usr/bin/mplayer -slave -quiet #{Shellwords.shellescape(track.location)}"
      @pid, @stdin, @stdout, @stderr = Open4.popen4(cmd)
      @paused = false
      @extra_lines = 0

      until @stdout.gets["playback"]
      end

      @quit_hook_active = false
      @quit_hook = Thread.new do
        Process.wait(@pid)
        @quit_hook_active = true
        on_quit.call
      end
    end

    def command(cmd, options = {})
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
      end
    end

    def quit
      @quit_hook.kill unless @quit_hook_active
      command "quit" if alive?
    end

    def alive?
      Process.getpgid(@pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end
