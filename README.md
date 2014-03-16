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

## Commands

### p

`p` is like a play/pause button. If the player is paused, it unpauses. If the player is playing, then it pauses. If the player is stopped, then it starts playing.

### mpd

`mpd` gives you an instance of the `MPDClient` object, which you can use to send any `mpd` command that isn't available in Listlace yet. This'll probably be removed once I actually implement all the commands.

