#!/bin/false

function print_usage() {
    echo "Usage: $0 CONFIG_DIR [TIMEOUT]"
}

function parse_args() {
    if [[ -z "$1" ]]
    then
        return 1
    fi

    declare -n _args="$1"
    shift

    [ "$#" -eq 1 -o "$#" -eq 2 ] || { print_usage; return 1; }

    _args['config_dir']="$(realpath "$1")"
    _args['timeout_s']="$2"
}
