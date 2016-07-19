#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

UNAME="$(uname)"
CMD="$(basename "$0")"


INSTALLDIR="${SCRIPTDIR}/../install"
rm -rf "${INSTALLDIR}"

if [[ "${UNAME}" == "Darwin" ]]; then
    BUILD_SUBDIR=buildbot_incremental
    BUILD_OPTION="--preset=buildbot_incremental"
#    BUILD_OPTION="--preset=buildbot_incremental_my"
elif [[ "${UNAME}" == "Linux" ]]; then
    BUILD_SUBDIR=buildbot_linux
    BUILD_OPTION="--preset=buildbot_linux install_destdir=${INSTALLDIR} installable_package=${INSTALLDIR}-${TIMESTAMP}.tar.gz"
#    BUILD_SUBDIR=buildbot_incremental
#    BUILD_OPTION="--preset=buildbot_incremental_linux_my"
else
    echo "Error: unknown operating system: ${UNAME}"
    exit 1
fi

#BUILDROOT="${SCRIPTDIR}/../build/${BUILD_SUBDIR}"
#rm -rf "${BUILDROOT}"


echo "Building swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

cmd="${SCRIPTDIR}/../swift/utils/build-script ${BUILD_OPTION} 2>&1 | tee -a ${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "$cmd" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
eval $cmd

echo "Building swift finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
