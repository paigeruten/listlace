# listlace

listlace is a music player that does Ruby. It's divided into two main parts:
Playlists and the Player.

The idea is, first you make a playlist:

    >> my_playlist = album("turning the mind", "origin of symmetry")
    => playlist (23 tracks)

Then you play it:

    >> p my_playlist
    Playlist: playlist (1 / 23)
    Turning The Mind - Maps (0:00 / 5:58)

Playlists can be saved of course. You are encouraged to create an exorbitant
amount of playlists, saved under simple, Symbol-friendly names. For example:

    >> song("concerto no 3") & composer(:rachmaninov)
    => playlist (3 tracks)
    >> _.save :rach3
    => rach3 (3 tracks)

Then whenever you want to hear Rachmaninov's 3rd Piano Concerto:

    >> p :rach3
    Playlist: rach3 (1 / 3)
    Concerto No 3 in D minor, op 30 - 1 Allegro ma non tanto - Sergei Rachmaninov (0:00 / 17:18)

## Install

It's a gem. So do this:

    $ gem install listlace

## Usage

The gem installs an executable. So do this:

    $ listlace
    Hello, you have 0 songs.
    >>

Now you can start typing commands. To get some songs in there, you can import
your iTunes library:

    >> import :itunes, "/Users/jeremy/Music/iTunes/iTunes Music Library.xml"

Or you can add a file or folder yourself with the add() command:

    >> add "/Users/jeremy/Music"

Now you're ready to play.

## Playlists

A playlist is just an Array. So you can add playlists together, call #filter on
them, do set operations, and so on.

Playlists are created using selectors. These are methods that select tracks from
your library based on certain criteria. So if you call the artist() method and
pass it a String or Symbol, it will give you a playlist of all the tracks whose
artist field contains your query. There's a selector for pretty much every track
property.

Some special selectors are all(), none(), and playlist(). all() and none() do
the obvious. playlist() loads a saved playlist. Just give it the name of the
playlist you want, preferrably as a Symbol.

For a full list of selectors, see the docs.

## Player

The Player actually plays your playlists. There are all sorts of crazy buttons
and dials on it that you can use to influence playback. Stop, pause, skip,
fast-forward, and so on. Just what you'd expect.

To start playing a playlist, use the p() method:

    >> p all
    Playlist: all (1 / 5901)
    Breathing New Air - 4 Strings  (0:00 / 3:20)

The Player contains a queue, which is a playlist. This is the only playlist it's
allowed to play. When you play a playlist, the p() command is just queueing that
playlist for you and then hitting the play button.

To queue songs yourself, use the q() command:

    >> q :rach2
    => queue (3 tracks)
    >> q :rach3
    => queue (6 tracks)
    >> p
    Playlist: queue (1 / 6)
    Concerto No 2 in C minor, op 18 - 1 Moderato - Sergei Rachmaninov (0:00 / 10:48)

For a full list of playback commands, see the docs.
