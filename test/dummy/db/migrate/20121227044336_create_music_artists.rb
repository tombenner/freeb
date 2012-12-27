class CreateMusicArtists < ActiveRecord::Migration
  def change
    create_table :music_artists do |t|
      t.string :freebase_id
      t.string :name
      t.text :description
      t.datetime :active_start
      t.datetime :active_end
      
      t.timestamps
    end

    add_index :music_artists, :freebase_id
  end
end