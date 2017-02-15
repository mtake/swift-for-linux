#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

UNAME="$(uname)"
CMD="$(basename "$0")"

# NOTE: build swift standard library for single-threaded code
# (equivalent to passing "-Xfrontend -assume-single-threaded" to the swift compiler)
#export SWIFT_ASSUME_SINGLE_THREADED=1

BUILD_SCRIPT=${SCRIPTDIR}/../swift/utils/build-script

INSTALLDIR="${SCRIPTDIR}/../install"

if [[ "${UNAME}" == "Darwin" ]]; then
    PRESET=buildbot_incremental_my
    if [[ -z "$(${BUILD_SCRIPT} --show-presets | grep ${PRESET})" ]]; then
        PRESET=buildbot_incremental
    fi
    BUILD_OPTION="--preset=${PRESET}"
    BUILD_SUBDIR=buildbot_incremental
elif [[ "${UNAME}" == "Linux" ]]; then
    PRESET=buildbot_incremental_linux_my
    if [[ -n "$(${BUILD_SCRIPT} --show-presets | grep ${PRESET})" ]]; then
        BUILD_OPTION="--preset=${PRESET}"
        BUILD_SUBDIR=buildbot_incremental
    else
        PRESET=buildbot_linux_my
        if [[ -z "$(${BUILD_SCRIPT} --show-presets | grep ${PRESET})" ]]; then
            PRESET=buildbot_linux
        fi
        BUILD_OPTION="--preset=${PRESET} install_destdir=${INSTALLDIR} installable_package=${INSTALLDIR}-${TIMESTAMP}.tar.gz"
        BUILD_SUBDIR=buildbot_linux
        rm -rf "${INSTALLDIR}"
    fi
else
    echo "Error: unknown operating system: ${UNAME}"
    exit 1
fi

#BUILDROOT="${SCRIPTDIR}/../build/${BUILD_SUBDIR}"
#rm -rf "${BUILDROOT}"


echo "Building swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

cmd="${BUILD_SCRIPT} ${BUILD_OPTION} 2>&1 | tee -a ${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "$cmd" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
eval $cmd

echo "Building swift finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
