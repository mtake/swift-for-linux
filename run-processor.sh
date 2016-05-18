#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

BINDIR="${SCRIPTDIR}/bin"

RESULTSDIR="${SCRIPTDIR}/benchmark/operf-results"


if [[ ! -d "${RESULTSDIR}" ]]; then
    echo "Execute ./run-operf.sh in benchmark first."
    exit 1
fi


echo "Post processing profiling results started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

pushd ${RESULTSDIR} > /dev/null

java -cp ${BINDIR} SwiftOperfProcessor

popd > /dev/null

echo "Post processing profiling results finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "A CSV file \"${RESULTSDIR}/output.csv\" was created."
