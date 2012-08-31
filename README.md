# Listlace

Listlace is a music player that does Ruby. Here's how it works:

First add your music library.

    >> add "/path/to/Music"
    1067 songs added.

...Or import your iTunes library.

    >> import :itunes, "/path/to/iTunes/iTunes Music Library.xml"

Once your library is in place, start grouping your songs into playlists.

    >> save artist("muse"), :muse
    => muse (108 tracks)

Finally, go ahead and play your playlists.

    >> p :muse
    Playlist: muse (108 tracks)
    Blackout - Muse (0:00 / 4:22)

## Install

It's a gem, so do this:

    $ gem install listlace

You also need mplayer in your $PATH, if you want to atually play your music.

## Usage

The gem gives you an executable, so do this:

    $ listlace
    Hello, you have 0 songs.
    >>

Now you're ready to play.

## Library

...

## Playlists

...

## The Player

...
