class MusicArtist < ActiveRecord::Base
  freeb do
    type "/music/artist"
    properties "description", "active_start", "active_end"
    topics :genres => "genre"
  end
end