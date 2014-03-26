class Listlace
  module TimeHelpers
    extend self

    # Helper method to format a number of seconds as a string like "1:03:56".
    def format_time(seconds, options = {})
      negative = false
      if seconds < 0
        negative = true
        seconds = -seconds
      end

      hours = seconds / 3600
      minutes = (seconds / 60) % 60
      seconds = seconds % 60
      sign = negative ? "-" : ""

      if hours > 0
        "%s%d:%02d:%02d" % [sign, hours, minutes, seconds]
      else
        "%s%d:%02d" % [sign, minutes, seconds]
      end
    end

    # Helper method to parse a string like "1:03:56" and return the number of
    # seconds that time length represents.
    def parse_time(string)
      negative = false
      if string[0] == "-"
        negative = true
        string = string[1..-1]
      end

      parts = string.split(":", -1).map(&:to_i)

      raise ArgumentError, "too many parts" if parts.length > 3
      raise ArgumentError, "can't parse negative numbers" if parts.any? { |x| x < 0 }

      parts.unshift(0) until parts.length == 3
      hours, minutes, seconds = parts
      total_seconds = hours * 3600 + minutes * 60 + seconds

      total_seconds * (negative ? -1 : 1)
    end
  end
end

