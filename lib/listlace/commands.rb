class Listlace
  module Commands
    REPEAT_SYMBOL = "\u221E"
    TIMES_SYMBOL = "\u00D7"

    def p
      case mpd.status["state"]
      when "play"
        mpd.pause(1)
      when "pause"
        mpd.pause(0)
      when "stop"
        mpd.play
      end
    end
  end
end

