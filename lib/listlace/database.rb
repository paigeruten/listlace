module Listlace
  module Database
    extend self

    ADAPTER = "sqlite3"
    PATH = "#{Listlace::DIR}/library.sqlite3"

    def connect
      ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: PATH)
    end

    def exists?
      File.exists? PATH
    end

    def delete
      FileUtils.rm PATH
    end

    def wipe
      delete
      connect
      generate_schema
    end

    def generate_schema
      ActiveRecord::Schema.define do
        create_table :tracks do |t|
          t.integer :original_id
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
end
