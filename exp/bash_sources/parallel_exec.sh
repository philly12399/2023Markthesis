#!/bin/false

function generate_commands() {
    declare -g _repo_dir
    declare -n _commands="$1"
    shift

    if [[ ! -v repo_dir ]]
    then
        echo '$repo_dir is not set' >&2
        return 1
    fi

    ## Parse arguments
    function print_usage() {
        echo "Usage: generate_commands COMMANDS_ARRAY -r COMMAND_FILE -c CONFIG_DIR -p RUST_PROFILE"
        echo
        echo
        echo "Arguments:"
        echo "  COMMAND_FILE\ta text file of a list of shell commands"
        echo "  CONFIG_DIR\tdirectory of configuration files"
        echo "  RUST_PROFILE\tRust compilation profile"
        echo
        echo "Example:"
        echo "  generate_commands -r scripts/commands/all.txt -c config/2022-03-PingTung -p release -t 60"
    }

    ## Configuration
    while getopts "r:c:p:" opt $@; do
        case $opt in
            r)
                if [ -z "$OPTARG" ]
                then
                    echo "-r requires an argument" >&2
                    return 1
                fi
                local command_file="$OPTARG"
                ;;
            c)
                if [ -z "$OPTARG" ]
                then
                    echo "-c requires an argument" >&2
                    return 1
                fi

                local config_dir="$OPTARG"
                ;;
            p)
                if [ -z "$OPTARG" ]
                then
                    echo "-p requires an argument" >&2
                    return 1
                fi

                local rust_profile="$OPTARG"
                ;;
            *)
                print_usage
                return 1
                ;;
        esac
    done

    ## Check variables
    [[ -v command_file ]] || {
        print_usage;
        return 1;
    }

    [[ -v config_dir ]] || {
        print_usage;
        return 1;
    }

    [[ -v rust_profile ]] || {
        print_usage;
        return 1;
    }

    ## Run commands
    export repo_dir
    export config_dir
    export rust_profile

    mapfile -t _commands < <(awk '!(/^\s*#/ || /^\s*$/)' "$command_file" | envsubst)
}

function run_gnu_parallel() {
    function print_usage() {
        echo "Usage: run_gnu_parallel COMMANDS_ARRAY LOG_DIR TIMEOUT" >&2
    }

    # 1st arg
    declare -n _commands="$1"
    shift || { print_usage; return 1; }

    # 2nd arg
    local _log_dir="$1"
    shift || { print_usage; return 1; }

    # 3rd arg
    case $# in
        0)
            local timeout_arg=""
        ;;
        1)
            local timeout_arg="--timeout $1"
        ;;
        *)
            print_usage
            return 1
        ;;
    esac

    # Run GNU parallel
    local log_dir="${_log_dir}/$(date --rfc-3339=ns | tr ' ' 'T' | tr ':' '-')"
    echo "Logs are saved to $log_dir" >&2

    printf "'%s'\n" "${commands[@]}" | \
        parallel $timeout_arg --no-run-if-empty --jobs 0 --results "$log_dir/{/.}"
}
