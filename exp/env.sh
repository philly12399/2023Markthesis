#!/bin/false
pushd "$(dirname $(realpath "${BASH_SOURCE[0]}"))" >/dev/null 2>&1
source "bash_sources/bash_opts.sh"
source "bash_sources/config.sh"
source "bash_sources/job.sh"
source "bash_sources/parallel_exec.sh"
popd >/dev/null 2>&1

module_config="$(realpath "$PWD/config/modules")"

