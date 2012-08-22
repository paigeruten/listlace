module Listlace
  class Playlist < ActiveRecord::Base
    has_many :playlist_items
    has_many :tracks, through: :playlist_items, order: "playlist_items.position ASC"
  end
end
