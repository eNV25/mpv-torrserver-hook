# mpv-torrserver-hook

The [TorrServer](https://github.com/YouROK/TorrServer) must be installed and running. You must configure the endpoint used by your TorrServer instance. By default `http://localhost:8090` is used.

```conf
# ~/.config/mpv/script-opts/torrserver_hook.conf
server=http://my-server.lan:8090
```

## Dependencies

- curl (only to upload local `.torrent` files, not necessary for magnet links and `.torrent` links)
