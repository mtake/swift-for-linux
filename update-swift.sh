#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

CMD="$(basename "$0")"


pushd ${SCRIPTDIR}/../swift > /dev/null


echo "Updating swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

git pull

popd > /dev/null
