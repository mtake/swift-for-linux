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

java -cp ${BINDIR} SwiftOperfProcessor ${RESULTSDIR}/opreport-l-*.txt

echo "Post processing profiling results finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "A CSV file \"output.csv\" was created."
