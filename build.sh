#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

UNAME="$(uname)"
CMD="$(basename "$0")"

INSTALLDIR="${SCRIPTDIR}/../install"
rm -rf "${INSTALLDIR}"
#BUILDROOT="${SCRIPTDIR}/../build/buildbot_linux"
#rm -rf "${BUILDROOT}"

echo "Building swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

cmd="${SCRIPTDIR}/../swift/utils/build-script --preset=buildbot_linux install_destdir=${INSTALLDIR} installable_package=${INSTALLDIR}-${TIMESTAMP}.tar.gz 2>&1 | tee -a ${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "$cmd" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
eval $cmd

echo "Building swift finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
