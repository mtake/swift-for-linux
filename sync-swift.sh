#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

CMD="$(basename "$0")"


pushd ${SCRIPTDIR}/../swift > /dev/null


echo "Updating swift started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "Fetch the branches and their respective commits from the upstream repository." | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
git fetch upstream

echo "Check out your fork's local master branch." | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
git checkout master

echo "Merge the changes from upstream/master into your local master branch." | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
git merge upstream/master


echo "Updating swift finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

echo "To update your fork on GitHub, you must push your changes NOW."


popd > /dev/null
