# ♫> Listlace

Listlace is an mpd (music player daemon) client that uses a Ruby prompt as the interface, allowing you to use the power of Ruby to query your music library and build playlists.

## Install

It's a gem, so do this:

    $ gem install listlace

Listlace is an mpd client, so make sure mpd is installed and running in the background.

## Usage

The gem gives you an executable, so do this:

    $ listlace
    ♫>

It gives you a prompt, which is just a Ruby prompt, with the commands below implemented as methods.

## Selectors

Query your music library and build playlists using selectors. There are selectors for each tag (artist, album, title, etc.) As an example, here is how `artist` works:

    ♫> artist "thirsty cups"
    => [8 songs]

It returned an Array of 8 Songs. To do an exact, case-sensitive search, use `artist_exact`:

    ♫> artist_exact "thirsty cups"
    => []
    ♫> artist_exact "The Thirsty Cups"
    => [8 songs]

The first one didn't match anything, the second one matched the same 8 songs.

In addition to tag selectors, here are some special selectors:

### all

`all` returns all the songs in your library.

    ♫> all
    => [3560 songs]

### none

`none` returns an empty playlist.

    ♫> none
    => []

### search

`search` will match **any** tag that contains your query.

    ♫> search "thirsty"
    => [8 songs]

### where, where\_exact

`where` and `where_exact` let you specify multiple queries for different tags:

    ♫> where(artist: "thirsty", title: "belljar")
    => [1 song]

## Commands

### p

`p` is like a play/pause button. If the player is paused, it unpauses. If the player is playing, then it pauses. If the player is stopped, then it starts playing.

### stop

`stop` stops playback.

### mpd

`mpd` gives you an instance of the `MPDClient` object, which you can use to send any `mpd` command that isn't available in Listlace yet. This'll probably be removed once I actually implement all the commands.

