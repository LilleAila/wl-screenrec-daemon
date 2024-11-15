fifo_path="/tmp/screenrec"

# not the initial value, it's actually the value to use after the first toggle
recording=true
rec_file="$HOME/Videos/recording_tmp.mp4"
rec_started=""
rec_pid=""
rec_args=""
rec_history="15"

reset_rec() {
  if [ -n "$rec_pid" ] && kill -0 "$rec_pid" 2>/dev/null; then
    kill -INT "$rec_pid"
  fi
  if [ -f "$rec_file" ]; then
    echo "Error: file $rec_file already exists!"
    exit 1
  fi
  wl-screenrec --history "$rec_history" --filename "$rec_file" ${rec_args[@]:+"${rec_args[@]}"} > /dev/null &
  rec_pid="$!"
}

record() {
  if [[ "$recording" = true ]]; then
    recording=false
    echo "$rec_pid"
    if [ -n "$rec_pid" ] && kill -0 "$rec_pid" 2>/dev/null; then
      kill -USR1 "$rec_pid"
      notify-send "Starting screen recording from the last $rec_history seconds" -t 1000
      rec_started=$(date +"%Y-%m-%dT%H:%M:%S")
    fi
  else
    if [ -n "$rec_pid" ] && kill -0 "$rec_pid" 2>/dev/null; then
      kill -INT "$rec_pid"
      rec_pid=""
    fi
    output_file="$HOME/Videos/screenrec_${rec_started}.mp4"
    mv "$rec_file" "$output_file"
    wl-copy -t text/uri-list <<< "file://$output_file"
    notify-send "Recording saved to $output_file and copied to clipboard." -t 1000
    reset_rec
    recording=true
  fi
}

read_args() {
  if [ "$#" -gt  0 ]; then
    while [ "$1" != "--" ] && [ -n "$1" ] && [ "$#" -gt 0 ]; do
      case $1 in
        "--history"|"-h")
          if [[ -n $2 && ! $2 =~ ^-- ]]; then
              rec_history=$2
              shift
          else
              echo "Error: --history requires a value"
              exit 1
          fi
          ;;
        *)
          echo "Error: unknown option $1"
          exit 1
      esac
      shift
    done
    if [ "$1" == "--" ]; then
      shift
      rec_args=( "$@" )
    fi
  fi
}

cleanup() {
  # shellcheck disable=SC2317
  if [[ -p "$fifo_path" ]]; then
    echo 0 > "$fifo_path" & # it's blocking, so it won't be able to read unless with &
  fi
}

daemon() {
  shift
  read_args "$@"
  if [[ -p $fifo_path ]]; then
    echo "Daemon is already running!"
    exit 1
  fi
  reset_rec
  mkfifo $fifo_path
  trap cleanup INT TERM HUP EXIT

  while true; do
    if read -r line < "$fifo_path"; then
      if [[ "$line" == "1" ]]; then
        record
      elif [[ "$line" == "0" ]]; then
        if [ -n "$rec_pid" ] && kill -0 "$rec_pid" 2>/dev/null; then
          kill -INT "$rec_pid"
        fi
        rm -f "$fifo_path"
        rm "$rec_file"
        exit 0
      fi
    fi
  done
}

toggle() {
  if [[ -p "$fifo_path" ]]; then
    echo 1 > "$fifo_path"
  else
    echo "Error: daemon is not running!"
    exit 1
  fi
}

stop_daemon() {
  if [[ -p "$fifo_path" ]]; then
    cleanup
  else
    echo "Error: daemon is not running!"
    exit 1
  fi
}

script_help() {
  printf "%b\n" "$(cat <<EOF
Wrapper around wl-screenrec to easily record the last few seconds and copy the video to the clipboard

\e[1;4mUsage:\e[0m
  \e[1mwl-screenrec-daemon --help, -h\e[0m
    Show this help text
  \e[1mwl-screenrec-daemon --daemon <options> -- <args>\e[0m
    Start the daemon. This should always run in the background while your wayland session is running.
    <args> are passed directly to wl-screenrec.
    Available options are:
    \e[1m--history, -h\e[0m
      How many seconds of history to keep
      Default: 15
  \e[1mwl-screenrec-daemon --stop-daemon\e[0m
    Stop the daemon.
  \e[1mwl-screenrec-daemon --toggle\e[0m
    Start / stop the recording. This will include the last 15 seconds.
EOF
)"
}

case "${1:-}" in
  "--daemon")
    daemon "$@"
    exit 0
    ;;
  "--stop-daemon")
    stop_daemon
    exit 0
    ;;
  "--toggle")
    toggle
    exit 0
    ;;
  "-h"|"--help"|*)
    script_help
    exit 0
    ;;
esac
