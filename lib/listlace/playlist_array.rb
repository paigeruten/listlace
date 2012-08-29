module Listlace
  class PlaylistArray < Array
    attr_accessor :name, :model

    def initialize(tracks_or_playlist = [], name = :playlist)
      if tracks_or_playlist.is_a? Playlist
        replace tracks_or_playlist.tracks.to_a
        @name = tracks_or_playlist.name
      else
        replace tracks_or_playlist.to_a
        @name = name.to_s
      end
    end

    def save(name = nil)
      @name ||= name
      if @name && (model = Playlist.find_by_name(@name))
        model.playlist_items.destroy_all
        model.name = @name
      else
        model = Playlist.new(name: @name)
      end

      if model.save
        each.with_index do |track, i|
          item = PlaylistItem.new(position: i)
          item.playlist = model
          item.track = track
          item.save!
        end
        model
      else
        false
      end
    end

    def <<(other)
      if other.is_a? Track
        super
      else
        other.each do |track|
          self << track
        end
      end
    end

    def +(other)
      result = self.dup
      result << Listlace.playlist(other)
      result
    end

    def &(other)
      replace super
    end

    def shuffle_except(track)
      ary = dup
      dup.shuffle_except! track
      dup
    end

    def shuffle_except!(track)
      replace([track] + (self - [track]).shuffle)
    end

    def to_s
      "%s (%d track%s)" % [@name || "playlist", length, ("s" if length != 1)]
    end

    def inspect
      to_s
    end

    # override pry
    def pretty_inspect
      inspect
    end
  end
end
