module Listlace
  class PlaylistItem < ActiveRecord::Base
    belongs_to :playlist
    belongs_to :track
  end
end
