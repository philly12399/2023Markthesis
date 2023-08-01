TIMEOUT = ""
SHELL := /bin/bash

cache_pcd_process:
	@ ./cache-pcd-process.sh ${TIMEOUT}

clustering-detect-from-cache:
	@ ./clustering-detect-from-cache.sh ${TIMEOUT}

learning-based-detect-from-cache:
	@ ./learning-based-detect-from-cache.sh ${TIMEOUT}

run_all:
	@ ./run_all.sh ${TIMEOUT}

build:
	@ source ./env.sh && build_rust_bin

clean:
	@ rm -rvf output
	@ rm -rvf cache
