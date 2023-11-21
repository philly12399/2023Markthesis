#!/bin/false

## Parse arguments
function print_usage() {
    echo "Usage: $0 -r COMMAND_FILE -c CONFIG_DIR [-t TIMEOUT]"
    echo
    echo
    echo "Arguments:"
    echo "  COMMAND_FILE\ta text file of a list of shell commands"
    echo "  CONFIG_DIR\tdirectory of configuration files"
    echo "  TIMEOUT\toptional timeout in secodns"
    echo
    echo "Example:"
    echo "  $0 -r scripts/commands/all.txt -c config/2022-03-PingTung -t 60"
}

function parse_args() {
    if [[ -z "$1" ]]
    then
        return 1
    fi

    declare -n _args="$1"
    shift

    while getopts "r:c:t:h:" opt $@; do
        case $opt in
            r)
                if [ -z "$OPTARG" ]
                then
                    echo "-r requires an argument"
                    return 1
                fi
                _args[command_file]="$OPTARG"
                ;;
            c)
                if [ -z "$OPTARG" ]
                then
                    echo "-c requires an argument"
                    return 1
                fi

                _args[config_dir]="$OPTARG"
                ;;
            t)
                if [ -z "$OPTARG" ]
                then
                    echo "-t requires an argument"
                    return 1
                fi

                _args[timeout_s]="$OPTARG"
                ;;
            h)
                print_usage
                exit
                ;;
            *)
                print_usage
                return 1
                ;;
        esac
    done
}
