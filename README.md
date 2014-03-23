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

You can also pass in a `Regexp` or a `Symbol`:

    ♫> artist :the_thirsty_cups
    => [8 songs]
    ♫> artist /the thirst(y|ier|iest) cups/
    => [8 songs]

Underscores in symbols are interpreted as spaces.

You can pass multiple queries to a selector, and it will select all songs that match **any** of those queries:

    ♫> _why = artist(:the_thirsty_cups, :moonboots, :the_child_who_was_a_keyhole)
    => [33 songs]

You can chain selectors together to narrow down a playlist:

    ♫> _why.album(:elfin_princess).title(/^the/)
    => [1 song]

There are also numeric selectors, to which you can pass a `Range` to match against or a `Hash` that specifies one or more comparison operators:

    ♫> year 2000, 2004
    => [362 songs]
    ♫> year 1990..1999
    => [521 songs]
    ♫> year lt: 1970
    => [76 songs]
    
The comparison operators are `:eq`, `:ne`, `:gt`, `:ge`, `:lt`, and `:le`. You can also just use `:==`, `:>`, `:>=`, `:<`, and `:<=`.

Here's a list of all tag selectors: `title`, `title_exact`, `artist`, `artist_exact`, `album`, `album_exact`, `genre`, `genre_exact`, `track`, `disc`, `year`, and `time`.

In addition to tag selectors, here are some special selectors:

### all

`all` returns all the songs in your library.

    ♫> all
    => [3560 songs]

### none

`none` returns an empty playlist.

    ♫> none
    => []

## Commands

### p

`p` is like a play/pause button. If the player is paused, it unpauses. If the player is playing, then it pauses. If the player is stopped, then it starts playing. If you pass it a playlist, it will set the queue to that playlist and begin playing it.

    ♫> p
    ♫> p album :in_the_faxed_atmosphere

### q

`q` without any arguments returns the queue (the current playlist). If you call `q` with a playlist as an argument, it will replace the queue with that playlist.


    ♫> q genre :trance
    ♫> q
    => [53 songs]

### stop

`stop` stops playback.

    ♫> stop

### list

`list` with no arguments lists all the songs in your music library. If you pass it a playlist, it will list all the songs in that playlist.

    ♫> list
    Air - 10 000 Hz Legend - Electronic Performers
    Air - 10 000 Hz Legend - How Does It Make You Feel?
    Air - 10 000 Hz Legend - Radio #1
    ...
    ♫> list title :fish
    Eisley - Currents - Blue Fish
    Moonboots - Elfin Princess - The Fish Said Hello
    Radiohead - In Rainbows - Weird Fishes/Arpeggi
    Thee More Shallows - A History of Sport Fishing - A History of Sport Fishing

### artists

`artists` with no arguments lists all the artists in your music library. If you pass it a playlist, it will list all the artists in that playlist.

    ♫> artists
    Air (55 songs)
    Amplifier (53 songs)
    Andrew Bird (93 songs)
    ...
    ♫> artists genre(:trance)
    Infected Mushroom (13 songs)
    Gouryella (3 songs)
    Safri Duo feat. Clark Anderson (6 songs)
    Safri Duo (16 songs)

### albums

`albums` with no arguments lists all the albums in your music library. If you pass it a playlist, it will list all the albums in that playlist.

    ♫> albums
    Air - 10 000 Hz Legend (11 songs)
    Air - Love 2 (12 songs)
    Air - Moon Safari (10 songs)
    ...
    ♫> albums artist(:infected_mushroom)
    Infected Mushroom - Converting Vegetarians (22 songs)
    Infected Mushroom - IM the Supervisor (9 songs)
    Infected Mushroom - Legend of the Black Shawarma (11 songs)
    Infected Mushroom - Stretched (4 songs)
    Infected Mushroom - Vicious Delicious (11 songs)

### genres

`genres` with no arguments lists all the genres in your music library. If you pass it a playlist, it will list all the genres in that playlist.

    ♫> genres
    Trance (53 songs)
    Hip-Hop (14 songs)
    Jazz (10 songs)
    ...
    ♫> genres title(:constantinople)
    TMBG (1 song)

### years

`years` with no arguments lists all the years in your music library. If you pass it a playlist, it will list all the years in that playlist.

    ♫> years
    2007 (205 songs)
    2010 (220 songs)
    2012 (148 songs)
    ...
    ♫> years artist :the_avalanches
    2000 (18 songs)

### mpd

`mpd` gives you an instance of the `MPDClient` object, which you can use to send any `mpd` command that isn't available in Listlace yet. This'll probably be removed once I actually implement all the commands.

    ♫> mpd.version
    => "0.16.0"

