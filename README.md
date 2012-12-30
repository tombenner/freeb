Freeb
=====
Store the world's knowledge in Rails models

Description
-----------

Freeb lets you easily create Rails models for just about any publicly available content type (e.g. Person, Film, etc) and populate them automagically with comprehensive data from [Freebase](http://www.freebase.com/). For example, a Person model would store data like [this](http://www.freebase.com/view/people/person).

Freebase has an enormous wealth of structured data for thousands of content types, each with their own specific, comprehensive schema (e.g. film's [schema](http://www.freebase.com/schema/film/film) and [records](http://www.freebase.com/view/film/film)). It's gigantic, with a scope and scale that are much larger and more comprehensive than Wikipedia's (see Available Data below).

For example, if you wanted to have bands and their albums and genres in your app, you would simply create a MusicArtist model that has type [/music/artist](http://www.freebase.com/schema/music/artist) and specify what associated data should be included (e.g. description, genres, albums, etc). When you call `MusicArtist.fcreate_by_name('The Beatles')`, data about The Beatles will be automagically pulled from Freebase and stored in a `music_artists` table that has bespoke columns.

Freeb lets you:

* Easily access and store just about every type of publicly available content (e.g. people, music, movies, sports teams, types of beer, etc). Freebase is like Wikipedia in database form, but with even more content.
* Quickly add a great deal of content and detail to your app
* Give your app a much wider and thorough variety of content types

Available Data
--------------

Freebase has thousands of content types, each with their own specific, comprehensive schema (e.g. [film's schema](http://www.freebase.com/schema/film/film)). The types range from very broad to very specific. Here are just a few of the types:

* [People](http://www.freebase.com/view/people/person)
* [Films](http://www.freebase.com/view/film/film)
* [Albums](http://www.freebase.com/view/music/album)
* [Consumer products](http://www.freebase.com/view/business/consumer_product)
* [Mass transit stops](http://www.freebase.com/view/metropolitan_transit/transit_stop)
* [Types of cheese](http://www.freebase.com/view/food/cheese)
* [Golf course architects](http://www.freebase.com/view/sports/golf_course_designer)

You can browse thousands of other types in the [Freebase schema](http://www.freebase.com/schema). This page shows domains, which each contain many types. Click on a type to see its schema.

Installation
------------

Add freeb to your Gemfile:

    gem 'freeb', :git => 'git://github.com/tombenner/freeb.git'

Install and run the migrations:

    rake freeb:install:migrations
    rake db:migrate

Creating Models
---------------

Create a model (without a migration) and specify its type and the information that will be stored with it: 

    class MusicArtist < ActiveRecord::Base
      freeb do
        type "/music/artist"
        properties "description", "active_start", "active_end"
        topics :genres => "genre"
      end
    end

`properties` specifies columns that will be in the MusicArtist table (in addition to id, freebase_id, and name), and `topics` are stored as FreebaseTopics (simple records with basically just a name and an ID). Please see Model Configuration below for details. 

Create the model's table:

    rails g freeb:migration MusicArtist
    rake db:migrate

You can now easily create MusicArtists, which will automatically retrieve and store all of the data specified in the model:

    artist = MusicArtist.fcreate_by_name('The Beatles')
    # <MusicArtist id: 1, freebase_id: "/en/the_beatles", name: "The Beatles", description: "The Beatles were an English rock band formed in Liv...", ...>

    artist.genres
    # [#<FreebaseTopic id: 1, freebase_id: "/en/rock_music", name: "Rock music", ...>, <FreebaseTopic id: 2, freebase_id: "/en/pop_music", name: "Pop music", ...>, ...]

To make associations between two Freeb models (e.g. MusicArtist has\_many Albums), use has_many:

    class MusicArtist < ActiveRecord::Base
      freeb do
        type "/music/artist"
        properties "description", "active_start", "active_end"
        topics :genres => "genre"
        has_many :albums => "album"
      end
    end

    class Album < ActiveRecord::Base
      freeb do
        type "/music/album"
        properties "release_date"
        topics :genres => "genre"
      end
    end

When you create a MusicArtist, its albums and genres will be created automatically:

    artist = MusicArtist.fcreate_by_name('The Beatles')
    # <MusicArtist id: 1, freebase_id: "/en/the_beatles", name: "The Beatles", description: "The Beatles were an English rock band formed in Liv...", ...>

    artist.albums.first
    # <Album id: 1, freebase_id: "/en/introducing_the_beatles", name: "Introducing...The Beatles", release_date: "1963-07-22 00:00:00", ...>

    artist.albums.first.genres
    # <FreebaseTopic id: 1, freebase_id: "/en/rock_music", name: "Rock music", ...>, #<FreebaseTopic id: 4, freebase_id: "/wikipedia/de_id/3375255", name: "Rock and roll", ...>

Model Configuration
-------------------

Model configuration consists of setting the `type` and setting the data that will be stored (`properties`, `topics`, `has_many`).

#### type

The Freebase type that the model corresponds to. [Here's](http://www.freebase.com/schema) a list of domains, which each contain many of types.

#### properties

A list of properties that will be stored in the model. You can see the available properties by clicking on a type in Freebase (see `type` above). For example, the list of properties for the type `/people/person` is [here](http://www.freebase.com/schema/people/person). To store Date of Birth in a Person model, you would write:

    properties "date_of_birth"

The type is inferred (`date_of_birth` is translated to `/people/person/date_of_birth`), but you can also specify the entire ID:

    properties "/people/person/date_of_birth"

Properties can then be accessed and used in queries like any other column:

    Person.first.date_of_birth
    Person.order('date_of_birth DESC')

#### topics

If a Freebase type has associated topics, you can store these either as simple records using `topics` or in a new dedicated model with `has_many` (see below).

The hash key is the name of the method through which they'll be accessed, and the hash value is the last part of the property ID (or the full ID; see `properties`).

For example, to store a [music artist](http://www.freebase.com/schema/music/artist)'s genres (/music/artist/genre), use:

    topics :genres => "genre"

You can then access those genres like any other association:

    MusicArtist.first.genres
    genre = MusicArtist.first.genres.first
    genre.music_artists

#### has_many

If you want to create associations between two Freeb models, use `has_many`. The hash key is the method through which the records will be accessed, and the hash value is the last part of the property ID (or the full ID; see `properties`). For example, if MusicArtist has_many Albums:

    class MusicArtist < ActiveRecord::Base
      freeb do
        type "/music/artist"
        properties "description", "active_start", "active_end"
        topics :genres => "genre"
        has_many :albums => "album"
      end
    end

    class Album < ActiveRecord::Base
      freeb do
        type "/music/album"
        properties "release_date"
        topics :genres => "genre"
      end
    end

Model Methods
-------------

In general, Freeb methods behave similarly to ActiveModel's CRUD methods, but are prefixed with an "f" and deal with creating and updating local objects with data from Freebase.

### Class Methods

#### fcreate(freebase_id)

Creates a new record using a Freebase ID:

    MusicArtist.fcreate('/en/the_beatles')
    # <MusicArtist id: 1, freebase_id: "/en/the_beatles", name: "The Beatles", description: "The Beatles were an English rock band formed in Liv...", ...>

You can also pass an array of Freebase IDs:

    MusicArtist.fcreate(['/en/the_beatles', '/en/the_beach_boys'])

Or use MQL to create all entities that match specific conditions:

    # Only create states with an area larger than 500,000 sq km
    UsState.fcreate([{"/location/location/area>" => 500000}])

#### fcreate\_by\_name(name)

Creates a new record using a name:

    MusicArtist.fcreate_by_name('The Beatles')
    # <MusicArtist id: 1, freebase_id: "/en/the_beatles", name: "The Beatles", description: "The Beatles were an English rock band formed in Liv...", ...>

Or an array of names:

    MusicArtist.fcreate_by_name(['The Beatles', 'The Beach Boys'])

#### fcreate_all
    
Creates records for every Freebase entity of the model's type:

    states = UsState.create_all
    states.count
    # 50

*Note that many types have huge numbers of entities in Freebase; if you want to create only a subset of those entities, you can use `fcreate(mql)` and specify filters in MQL (see `fcreate`).*

#### fnew(freebase_id)

Same as fcreate, but doesn't save the record.

#### fnew\_by\_name(name)

Same as fcreate\_by\_name, but doesn't save the record.

### Instance Methods

#### fupdate

Updates the record's Freebase data:

    MusicArtist.first.fupdate

#### fimage

Returns the Freebase image URL for the record:

    MusicArtist.first.fimage
    # "https://usercontent.googleapis.com/freebase/v1/image/en/the_beatles"

Freebase's image service also provides great options that let you specify the image's dimensions and other attributes. Every parameter that [their service](http://wiki.freebase.com/wiki/Image_Service) supports is supported:

    MusicArtist.first.fimage(:maxwidth => 200, :maxheight => 200)
    # "https://usercontent.googleapis.com/freebase/v1/image/en/the_beatles?maxheight=200&maxwidth=200"

API
---

Freeb also includes a wrapper for the Freebase API that uses smart objects. Properties can be retrieved from them using methods.

    beatles = Freeb.get('/en/the_beatles')

    beatles.description
    # "The Beatles were an English rock band formed in Liv..."

    beatles['/music/artist/active_start']
    # "1957"

#### Freeb.get(freebase_id)

Returns a topic object for the specified Freebase ID.

    Freeb.get('/en/the_beatles')
    # <Freeb::Topic:0x007fd9fbf6f978 @raw_data={"id"=>"/en/the_beatles", "name"=>"The Beatles"}>

#### Freeb.search(params)

Returns an array of topic objects for a Freebase search. The available parameters are listed [here](http://wiki.freebase.com/wiki/ApiSearch).

    Freeb.search(:keyword => 'The Beatles')
    # [#<Freeb::Topic:0x007fd6f22d4698 "id"=>"/en/the_beatles", "name"=>"The Beatles", "notable"=>{"name"=>"Musical Group", "id"=>"/music/musical_group"}, "lang"=>"en", "score"=>933.343811}>, #<Freeb::Topic:0x007fd6f22d4620 @raw_data={"mid"=>"/m/03j24kf", "id"=>"/en/paul_mccartney", "name"=>"Paul McCartney", "notable"=>{"name"=>"Musician", "id"=>"/m/09jwl"}, "lang"=>"en", "score"=>384.929718}>, #<Freeb::Topic:0x007fd6f22d45a8 @raw_data={"mid"=>"/m/01vsl3_", "id"=>"/en/john_lennon", "name"=>"John Lennon", 

#### Freeb.topic(mql)

Returns a topic object for the specified MQL. This is useful if you want to grab a number of properties using a single API call.

    mql = {
      :id => '/en/the_beatles',
      :name => nil,
      :'/music/artist/genre' => [{:id => nil, :name => nil}]
    }
    beatles = Freeb.topic(mql)
    
    beatles.name
    "The Beatles"

    beatles['/music/artist/genre']
    # [{"name"=>"Rock music", "id"=>"/en/rock_music"}, {"name"=>"Pop music", "id"=>"/en/pop_music"}, ...]

You can also use an array as an argument to get an array of topics:

    mql = [{
      :type => "/location/us_state",
      :id => nil,
      :name => nil
    }]
    Freeb.topic(mql)
    # [#<Freeb::Topic:0x007fe5ebe491d8 @raw_data={"type"=>"/location/us_state", "id"=>"/en/alabama", "name"=>"Alabama"}>, #<Freeb::Topic:0x007fe5ebe49160 @raw_data={"type"=>"/location/us_state", "id"=>"/en/alaska", "name"=>"Alaska"}>, ...]

#### Freeb.mqlread(mql)

Same as Freeb.topic, but returns the response's hash instead of a Freeb:Topic.

License
-------

Freeb is released under the MIT License. Please see the MIT-LICENSE file for details.