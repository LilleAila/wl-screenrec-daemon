# wl-screenrec-daemon

This is a daemon for [wl-screenrec](https://github.com/russelltg/wl-screenrec) that uses the `--history` feature to always be recording in the background.

## Usage:

```
$ wl-screenrec-daemon --help
Wrapper around wl-screenrec to easily record the last few seconds and copy the video to the clipboard

Usage:
  wl-screenrec-daemon --help, -h
    Show this help text
  wl-screenrec-daemon --daemon <options> -- <args>
    Start the daemon. This should always run in the background while your wayland session is running.
    <args> are passed directly to wl-screenrec.
    Available options are:
    --history, -h
      How many seconds of history to keep
      Default: 15
  wl-screenrec-daemon --stop-daemon
    Stop the daemon.
  wl-screenrec-daemon --toggle
    Start / stop the recording. This will include the last 15 seconds.
```

## home-manager module

The home-manager module is still a work-in-progress, but might work as long as `WAYLAND_DISPLAY` is properly passed to systemd services.
