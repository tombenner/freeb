require 'spec_helper'
class MusicArtist
  describe ".fnew" do
    let(:artist) { MusicArtist.fnew("/en/the_beatles") }

    it "returns a record with the correct name" do
      artist.name.should eql "The Beatles"
    end

    it "returns a record with at least one correct genre" do
      artist.genres.any? { |genre| genre.freebase_id == "/en/rock_music" }.should be_true
    end
  end

  describe ".fnew_by_name" do
    let(:artist) { MusicArtist.fnew_by_name("The Beatles") }

    it "returns a record with the correct Freebase ID" do
      artist.freebase_id.should eql "/en/the_beatles"
    end
  end

  describe ".fcreate" do
    let(:artist) { MusicArtist.fcreate("/en/the_beatles") }

    it "returns a valid record for a valid Freebase ID" do
      artist.should be_valid
    end

    it "returns nil for nil" do
      artist = MusicArtist.fcreate(nil)
      artist.should be_nil
    end

    it "returns nil for an empty Freebase ID" do
      artist = MusicArtist.fcreate("")
      artist.should be_nil
    end
  end

  describe ".fcreate_by_name" do
    let(:artist) { MusicArtist.fcreate_by_name("The Beatles") }

    it "returns a valid record for a valid Freebase ID" do
      artist.should be_valid
    end

    it "returns nil for nil" do
      artist = MusicArtist.fcreate_by_name(nil)
      artist.should be_nil
    end

    it "returns nil for an empty name" do
      artist = MusicArtist.fcreate_by_name("")
      artist.should be_nil
    end
  end
end