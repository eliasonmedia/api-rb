Ruby SDK for the [Outside.in API](http://developers.outside.in/)

## Prerequisites

### Developer account

To make API requests, register for an account at [developers.outside.in](http://developers.outside.in/) to receive a developer key and the shared secret you'll use with the key to sign requests.

### Dependencies

Gem dependencies are managed with [Bundler](http://gembundler.com/). Install them like so:

    $ bundle install

## Usage

    require 'oi'

    OI.key = 'faffledweomercraft'
    OI.secret = 'deadbeef'
    OI.logger.level = Logger::DEBUG # defaults to WARN

    # find locations by name
    # returns a hash with keys:
    #  * total - the total number of matched stories
    #  * locations - the array of matched locations up to the specified limit (default 10)
    data = OI::Location.named("Brooklyn")
    puts "Total matches: #{data[:total]}"
    data[:locations].each {|loc| puts "  #{loc.display_name}"}

    # displays:
    # Total matches: 624
    #   Brooklyn, NY
    #   Brooklyn, IL
    #   Brooklyn, IN
    # etc.

    # all story finders return the same data structure, a hash with keys:
    #  * total - the total number of matched stories
    #  * stories - the array of matched stories up to the specified limit (default 10)
    #  * location - the identified location -OR-
    #  * locations - the identified locations (when finding stories for multiple location UUIDs)

    # city, state and neighborhood names are case-insensitive.
    # states can be identified by name or postal abbreviation.

    # find stories for a zip code
    data = OI::Story.for_zip_code("11211")
    puts "Total stories for #{data[:location].display_name}: #{data[:total]}"
    data[:stories].each {|story| puts "  #{story.title} - #{story.feed_title}"}

    # displays:
    # Total stories for 11211: 438
    #   Fashionistas to Go Higher-End with 11K-Plus Feet at 550 Seventh - The New York Observer Real Estate
    #   Carlos C.'s Review of East River State Park - Brooklyn (3/5) on Yelp - Yelp Reviews New York
    #   What's going on Tuesday? - Brooklyn Vegan
    # etc.

    # find by state
    data = OI::Story.for_state("NY")

    # find by city
    data = OI::Story.for_city("New York", "New York")

    # find by neighborhood
    data = OI::Story.for_nabe("ny", "new york", "williamsburg")

    # find by location UUID
    data = OI::Story.for_uuids([
      "a02aa3e4-2aaa-41d7-b9d7-45642eb1c557", # Brooklyn, NY
      "98653b8d-fa8f-4d50-93b2-f3977a81f40c", # Brooklyn, Jacksonville, FL
    ])

## CLI

A set of Thor tasks is provided so that you can call API methods from the command line (read more about Thor at [http://github.com/wycats/thor](http://github.com/wycats/thor)).

The following examples assume you have Thor installed system-wide. If it's local to your bundle, then replace `thor` with `bundle exec thor`.

You can see all available OI tasks with this command:

    $ thor list oi

## Help

* Browse the API documentation: [http://developers.outside.in/docs](http://developers.outside.in/docs)
* Post questions in the help forum: [http://developers.outside.in/forum](http://developers.outside.in/forum)
