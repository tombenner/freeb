require 'spec_helper'
module Freeb
  describe ".get" do
    it "returns a topic with the correct name" do
      Freeb.get("/en/the_beatles").name.should eql "The Beatles"
    end
  end

  describe ".topic" do
    it "returns a topic with the correct name" do
      mql = {
        :id => '/en/the_beatles',
        :name => nil
      }
      Freeb.topic(mql).name.should eql "The Beatles"
    end

    it "returns array properties as an array" do
      mql = {
        :id => '/en/the_beatles',
        :'/music/artist/genre' => [{:id => nil, :name => nil}]
      }
      Freeb.topic(mql)["/music/artist/genre"].should include({"name" => "Rock music", "id" => "/en/rock_music"})
    end
  end
end