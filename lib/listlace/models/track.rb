module Listlace
  class Track < ActiveRecord::Base
    has_many :playlist_items
    has_many :playlists, through: :playlist_items

    def increment_skip_count
      increment! :skip_count
      update_column :skip_date, Time.now
    end

    def increment_play_count
      increment! :play_count
      update_column :play_date, Time.now
    end
  end
end
