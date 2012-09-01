module Listlace
  module Commands
    module PlayerCommands
      REPEAT_SYMBOL = "\u221E"
      TIMES_SYMBOL = "\u00D7"

      # The play command. With no arguments, it either resumes playback or starts
      # playing the queue. With arguments, it replaces the queue with the given
      # tracks and starts playing.
      def p(*tracks)
        if tracks.empty?
          if player.paused?
            player.resume
            status
          elsif player.started?
            if player.speed == 1
              player.pause
              status
            else
              player.speed = 1
              status
            end
          else
            if player.empty?
              puts "Nothing to play."
            else
              player.start
              status
            end
          end
        else
          player.clear
          q *tracks
          p
        end
      end

      # Stops playback. The queue is still intact, but goes back to the beginning
      # when playback is started again.
      def stop
        player.stop
        puts "Stopped."
      end

      # Start the current track from the beginning.
      def restart
        player.restart
        status
      end

      # Go back one song in the queue.
      def back(n = 1)
        player.back(n)
        if player.started?
          status
        else
          puts "End of queue."
        end
      end

      # Go directly to the next song in the queue.
      def skip(n = 1)
        player.skip(n)
        if player.started?
          status
        else
          puts "End of queue."
        end
      end

      # Seek to a particular position in the current track. If given an integer, it
      # will seek that many seconds forward or backward. If given a Range, it will
      # seek to that specific time, the first number in the Range representing the
      # minutes, the second number representing the seconds. You can also pass a
      # String like "1:23:45" to do the same thing. To seek to an absolute time in
      # seconds, do it like "seek(abs: 40)". To seek to a percentage, do something
      # like "seek(percent: 75)".
      def seek(where)
        player.seek(where)
        status
      end

      # Fast-forward at a particular speed. Induces the chipmunk effect, which I
      # find agreeable. Call p to go back to normal. You can also pass a value
      # smaller than one to slow down.
      def ff(speed = 2)
        player.speed = speed
        status
      end

      # Pass :all to start playing from the top of the queue when it gets to the
      # end. Pass :one to repeat the current track.
      def repeat(one_or_all = :all)
        player.repeat one_or_all
        status
      end

      # Turn off the repeat mode set by the repeat command.
      def norepeat
        player.repeat :off
        status
      end

      # Show various information about the status of the player. The information it
      # shows depends on what status types you pass:
      #
      #   :playlist - Shows the playlist that is currently playing
      #   :playing - Shows the current track
      #
      def status(*types)
        types = [:playlist, :playing] if types.empty?
        types.each do |type|
          case type
          when :playlist
            if player.started?
              track_number = player.current_track_index + 1
              num_tracks = q.length
              repeat_one = player.repeat_mode == :one ? REPEAT_SYMBOL : ""
              repeat_all = player.repeat_mode == :all ? REPEAT_SYMBOL : ""
              puts "Playlist: %s (%d%s / %d%s)" % [q.name, track_number, repeat_one, num_tracks, repeat_all]
            else
              puts "Playlist: %s" % [q]
            end
          when :playing
            if player.started?
              name = player.current_track.name
              artist = player.current_track.artist
              time = player.formatted_current_time
              total_time = player.current_track.formatted_total_time
              paused = player.paused? ? "|| " : ""
              speed = player.speed
              speed = speed != 1 ? "#{TIMES_SYMBOL}#{speed} " : ""
              puts "%s - %s (%s / %s) %s%s" % [name, artist, time, total_time, paused, speed]
            else
              puts "Stopped."
            end
          end
        end
        nil
      end

      # The queue command. Simply appends tracks to the queue. It creates a playlist
      # with the arguments you give it, so anything you can pass to the playlist()
      # method you can pass to this. It returns the queue, so you can use this
      # method as an accessor by not passing any arguments.
      def q(*args)
        player.queue playlist(*args)
        player.queue
      end

      # Clears the queue.
      def clear
        player.clear
        puts "Queue cleared."
      end

      # Shuffles the queue, keeping the current track at the top.
      def shuffle
        player.shuffle
        puts "Shuffled."
      end

      # Sorts the queue by a list of fields and directions in the form of a symbol,
      # or uses the proc given to it, which should take two Tracks and return -1, 0,
      # or 1.
      def sort(by = :artist_asc_album_asc_track_number_asc, &proc)
        if proc
          player.sort(&proc)
        else
          player.sort do |a, b|
            result = 0
            by.to_s.scan(/([a-z_]+?)_(asc|desc)(?:_|$)/).each do |column, direction|
              a_value = a.send(column)
              b_value = b.send(column)
              a_value = a_value.downcase if a_value.respond_to? :downcase
              b_value = b_value.downcase if b_value.respond_to? :downcase
              dir = (direction == "desc") ? -1 : 1
              if a_value != b_value
                if a_value.nil? || b_value.nil?
                  result = dir
                else
                  result = (a_value <=> b_value) * dir
                end
                break
              end
            end
            result
          end
        end
        puts "Sorted."
      end
    end
  end
end
