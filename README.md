# mpv-torrserver-hook

This script allows you to play torrents directly in [mpv](https://mpv.io/) by leveraging the power of [TorrServer](https://github.com/YouROK/TorrServer). It acts as a bridge between mpv and your running TorrServer instance, enabling seamless playback of torrent content.

**Key Features:**

- Plays torrent files (`.torrent`).
- Plays magnet links.
- Plays torrent links (HTTP/HTTPS links to `.torrent` files).
- Uses your existing TorrServer setup for downloading and streaming.

## Prerequisites

- **[TorrServer](https://github.com/YouROK/TorrServer) must be installed and running.** Make sure you have TorrServer set up and accessible.
- **mpv media player** ([https://mpv.io/](https://mpv.io/)).
- **curl (version 8.3.0 or later)**: This is required only for uploading local `.torrent` files to TorrServer. It is pre-installed on most systems.

## Installation

1.  Navigate to your mpv configuration directory:
    - **\*nix:** `~/.config/mpv/scripts/` (create the `scripts` directory if it doesn't exist)
    - **Windows:** `%APPDATA%/mpv/scripts/` or `portable_config/scripts/` (create the `scripts` directory if it doesn't exist)
2.  Download the [`torrserver_hook.lua`](./torrserver_hook.lua) script. Place this file in the `scripts` directory.

## Configuration

You need to configure the endpoint used by your TorrServer instance. By default, `http://localhost:8090` is assumed.

1.  Create a configuration file in your mpv `script-opts` directory:
    - **\*nix:** `~/.config/mpv/script-opts/torrserver_hook.conf` (create the `script-opts` directory if it doesn't exist)
    - **Windows:** `%APPDATA%/mpv/script-opts/torrserver_hook.conf` (create the `script-opts` directory if it doesn't exist)
2.  Open the `torrserver_hook.conf` file with a text editor and set the `server` option to the address and port of your TorrServer instance. For example:

    ```conf
    # *nix: ~/.config/mpv/script-opts/torrserver_hook.conf
    # Windows: %APPDATA%/mpv/script-opts/torrserver_hook.conf
    #          portable_config/script-opts/torrserver_hook.conf
    server=http://my-server.lan:8090
    ```

## Usage

Once installed and configured, you can play torrents in mpv using the following methods:

- **Playing a local `.torrent` file:** Simply open the `.torrent` file with mpv:
  ```bash
  mpv big-buck-bunny.torrent
  ```
- **Playing a magnet link:** Open the magnet link with mpv:
  ```bash
  mpv 'magnet:?xt=urn:btih:dd8255ecdc7ca55fb0bbf81323d87062db1f6d1c&dn=Big+Buck+Bunny&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=wss%3A%2F%2Ftracker.btorrent.xyz&tr=wss%3A%2F%2Ftracker.fastcast.nz&tr=wss%3A%2F%2Ftracker.openwebtorrent.com&ws=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2F&xs=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2Fbig-buck-bunny.torrent'
  ```
- **Playing a `.torrent` link (HTTP/S):** Open the link with mpv:
  ```bash
  mpv https://webtorrent.io/torrents/big-buck-bunny.torrent
  ```

## License

The license is [MIT No Attribution](./LICENSE), unless otherwise noted.
