module Listlace
  # This is a simple MPlayer wrapper, it just handles opening the MPlayer
  # process, hooking into when mplayer exits (when the song is done), and
  # issuing commands through the slave protocol.
  class MPlayer
    def initialize(track, &on_quit)
      cmd = "/usr/bin/mplayer -slave -quiet #{Shellwords.shellescape(track.location)}"
      @pid, @stdin, @stdout, @stderr = Open4.popen4(cmd)

      @quit_hook = Thread.new do
        Process.wait(@pid)
        on_quit.call
      end
    end

    def command(cmd)
      @stdin.puts cmd
    end

    def quit
      @quit_hook.kill
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
