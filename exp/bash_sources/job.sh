#!/bin/false

## prepare tmp dir
pid_tmp_dir="$(mktemp -d)"
pid_list_file="$pid_tmp_dir/pid"


## set exit tramp
function finalize() {
    [[ -f "$pid_list_file" ]] || {
        return 0;
    }

    while read pid; do
        pgid="$(ps -ef -o pgid= -p "$pid" | tr -d ' ')"
        if [ -n "$pgid" ] ; then
            echo killing pgid "$pgid" >&2
            kill -- "-$pgid"
        fi
    done < "$pid_list_file"
    rm -rf "$pid_tmp_dir"
    exit
}
trap "finalize" SIGINT SIGTERM EXIT


## job control commands

function start() {
    setsid "$@" &
    echo $! >> "$pid_list_file"
}

function build_rust_bin() {
    declare -g rust_profile

    [[ -v rust_profile ]] || {
        echo '$rust_profile is not set' >&2
        return 1
    }

    for f in $(ls "$PWD/bin"); do
        cd "${repo_dir}/rust-bin/${f}"
        cargo build --profile "${rust_profile}"
    done
}

function launch_rust_module() {
    declare -g rust_profile

    [[ -v rust_profile ]] || {
        echo '$rust_profile is not set' >&2;
        return 1;
    }

    module_name="$1"
    shift

    [[ ! -v 1 ]] || {
        custom_config="$1";
        shift;
    }

    exec_file="${PWD}/bin/$module_name"

    if [ ! -f "$exec_file" ]; then
        echo "${module_name} not existed! Build it first." >&2
        if ! cargo build --profile "$rust_profile" --bin "$module_name"; then
            echo "Failed to build." >&2
            return 1
        fi
    fi

    if [[ -v custom_config ]]; then
        start "$exec_file" --config "${custom_config}"
    else
        start "$exec_file" --config "${module_config}/${module_name}.json5"
    fi
    echo "Started ${module_name}!" >&2
}
