require "active_record"
require "active_support/core_ext/string"
require "plist"

module Listlace
  extend self

  def connect
    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: "db/library.sqlite3"
    )
  end

  def import_from_itunes(path_to_xml)
    data = Plist::parse_xml(path_to_xml)

    whitelist = Track.new.attributes.keys
    data["Tracks"].each do |_, row|
      # row already contains a hash of attributes almost ready to be passed to
      # ActiveRecord. We just need to modify the keys, e.g. change "Play Count"
      # to "play_count".
      attributes = row.inject({}) do |acc, (key, value)|
        attribute = key.gsub(" ", "").underscore
        acc[attribute] = value if whitelist.include? attribute
        acc
      end

      track = Track.new(attributes)
      track.save!
    end

    data["Playlists"].each do |playlist_data|
      playlist = Playlist.new(name: playlist_data["Name"])
      playlist.save!

      playlist_data["Playlist Items"].each.with_index do |(_, track_id), i|
        playlist_item = PlaylistItem.new(position: i)
        playlist_item.playlist = playlist
        if playlist_item.track = Track.where(id: track_id).first
          playlist_item.save!
        end
      end
    end
  end

  # Models

  class PlaylistItem < ActiveRecord::Base
    belongs_to :playlist
    belongs_to :track
  end

  class Track < ActiveRecord::Base
    has_many :playlist_items
    has_many :playlists, through: :playlist_items
  end

  class Playlist < ActiveRecord::Base
    has_many :playlist_items
    has_many :tracks, through: :playlist_items, order: "playlist_items.position ASC"
  end

  def generate_schema
    ActiveRecord::Schema.define do
      create_table :tracks do |t|
        t.string :name
        t.string :artist
        t.string :composer
        t.string :album
        t.string :album_artist
        t.string :genre
        t.string :kind
        t.integer :size
        t.integer :total_time
        t.integer :disc_number
        t.integer :disc_count
        t.integer :track_number
        t.integer :track_count
        t.integer :year
        t.datetime :date_modified
        t.datetime :date_added
        t.integer :bit_rate
        t.integer :sample_rate
        t.text :comments
        t.integer :play_count
        t.integer :play_date
        t.datetime :play_date_utc
        t.integer :skip_count
        t.datetime :skip_date
        t.integer :rating
        t.integer :album_rating
        t.boolean :album_rating_computed
        t.string :location
      end

      create_table :playlists do |t|
        t.string :name
        t.datetime :created_at
        t.datetime :updated_at
      end

      create_table :playlist_items do |t|
        t.references :playlist, null: false
        t.references :track, null: false
        t.integer :position
      end
    end
  end
end
