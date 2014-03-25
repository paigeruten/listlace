class Listlace
  module TimeHelpers
    extend self

    # Helper method to format a number of seconds as a string like "1:03:56".
    def format_time(seconds, options = {})
      raise ArgumentError, "can't format negative time" if seconds < 0

      hours = seconds / 3600
      minutes = (seconds / 60) % 60
      seconds = seconds % 60

      if hours > 0
        "%d:%02d:%02d" % [hours, minutes, seconds]
      else
        "%d:%02d" % [minutes, seconds]
      end
    end

    # Helper method to parse a string like "1:03:56" and return the number of
    # seconds that time length represents.
    def parse_time(string)
      parts = string.split(":", -1).map(&:to_i)

      raise ArgumentError, "too many parts" if parts.length > 3
      raise ArgumentError, "can't parse negative numbers" if parts.any? { |x| x < 0 }

      parts.unshift(0) until parts.length == 3
      hours, minutes, seconds = parts
      hours * 3600 + minutes * 60 + seconds
    end
  end
end

