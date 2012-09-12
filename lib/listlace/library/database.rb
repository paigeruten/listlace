module Listlace
  class Library
    module Database
      extend self

      def connect(adapter, path)
        ActiveRecord::Base.establish_connection(adapter: adapter, database: path)
      end

      def disconnect
        ActiveRecord::Base.remove_connection
      end

      def exists?(path)
        File.exists? path
      end

      def delete(path)
        FileUtils.rm path
      end

      def connected?
        ActiveRecord::Base.connected?
      end

      def connected_to?(path)
        if ActiveRecord::Base.connected?
          File.expand_path(path) == File.expand_path(ActiveRecord::Base.connection_config[:database])
        else
          false
        end
      end

      def wipe(adapter, path)
        delete(path)
        connect(adapter, path)
        generate_schema
      end

      def generate_schema
        ActiveRecord::Schema.define do
          create_table :tracks do |t|
            t.integer :original_id
            t.string :title
            t.string :artist
            t.string :composer
            t.string :album
            t.string :album_artist
            t.string :genre
            t.integer :total_time
            t.integer :disc_number
            t.integer :disc_count
            t.integer :track_number
            t.integer :track_count
            t.integer :year
            t.datetime :date_modified, null: false
            t.datetime :date_added, null: false
            t.integer :bit_rate
            t.integer :sample_rate
            t.text :comments
            t.integer :play_count, null: false, default: 0
            t.datetime :play_date
            t.integer :skip_count, null: false, default: 0
            t.datetime :skip_date
            t.integer :rating
            t.string :location, null: false
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
end
