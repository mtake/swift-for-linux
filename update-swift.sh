#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
if [[ ! -d "${LOGDIR}" ]]; then
    mkdir -p "${LOGDIR}"
fi

CMD="$(basename "$0")"


pushd ${SCRIPTDIR}/../swift > /dev/null


echo "Updating swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

git pull

popd > /dev/null
