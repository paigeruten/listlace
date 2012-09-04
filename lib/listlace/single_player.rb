module Listlace
  # A SinglePlayer takes care of playing a single track, and controlling the
  # playback with commands like pause, resume, seek, and so on. It typically
  # starts an external audio player process to do this job. This class is an
  # interface that is to be implemented for different audio players. Then the
  # user can choose which SinglePlayer to use based on what audio players they
  # have installed.
  #
  # All methods that perform an action should return false if the action isn't
  # applicable, and return a truthy value otherwise.
  class SinglePlayer
    # Returns true if a track is currently loaded, i.e. either playing or
    # paused.
    def active?
      raise NotImplementedError
    end

    # Returns true if a track is loaded and is paused.
    def paused?
      raise NotImplementedError
    end

    # Begin playing a track. The track should be either a String representing a
    # path to an audio file, or an object responding to #location. The &on_end
    # callback will be called when the track is finished playing.
    def play(track, &on_end)
      raise NotImplementedError
    end

    # Stop playback. Typically quits the external audio player process.
    def stop
      raise NotImplementedError
    end

    # Pauses playback.
    def pause
      raise NotImplementedError
    end

    # Resumes playback.
    def resume
      raise NotImplementedError
    end

    # Seek to a particular position in the track. Different types can be
    # supported, such as absolute, relative, or percent. All times are specified
    # in milliseconds. A NotImplementedError is raised when a certain type isn't
    # supported.
    def seek(where, type = :absolute)
      case type
      when :absolute
        raise NotImplementedError
      when :relative
        raise NotImplementedError
      when :perent
        raise NotImplementedError
      else
        raise NotImplementedError
      end
    end

    # Gets or sets the playback speed. If a new speed is passed as an argument,
    # it sets it to that speed. The speed is a multiplier. For example, for
    # double speed you'd call speed(2) and for half-speed you'd call speed(0.5).
    def speed(new_speed = nil)
      raise NotImplementedError
    end

    # Returns the current time into the song, in milliseconds.
    def current_time
      raise NotImplementedError
    end
  end
end
