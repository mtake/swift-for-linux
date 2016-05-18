#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

CMD="$(basename "$0")"

#
# TODO: check ssh connectivity to github.com
#
if [[ "$(hostname)" =~ "s72hs23-7" ]]; then
    CLONE_OPT="--clone"
else
    CLONE_OPT="--clone-with-ssh"
fi

echo "Updating dependencies started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

${SCRIPTDIR}/../swift/utils/update-checkout ${CLONE_OPT}

echo "Updating dependencies finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
