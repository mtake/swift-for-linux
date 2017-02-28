#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

UNAME="$(uname)"
CMD="$(basename "$0")"

# NOTE: set USE_HTTPS if no ssh connectivity
#USE_HTTPS=1

if [[ -n "${USE_HTTPS}" ]]; then
    UPDATE_OPT="--clone"
    NINJA_URL="https://github.com/ninja-build/ninja.git"
else
    UPDATE_OPT="--clone-with-ssh"
    NINJA_URL="git@github.com:ninja-build/ninja.git"
fi

# NOTE: swift should be updated manually because it may include local changes
UPDATE_OPT="${UPDATE_OPT} --skip-repository swift"

echo "Updating dependencies started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

${SCRIPTDIR}/../swift/utils/update-checkout ${UPDATE_OPT} 2>&1 | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

if [[ "${UNAME}" == "Darwin" ]]; then
    pushd ${SCRIPTDIR}/.. > /dev/null
    echo "--- Updating '$(pwd)/ninja' ---" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
    [[ -d "ninja" ]] || git clone ${NINJA_URL} 2>&1 | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
    (cd ninja; git checkout release 2>&1 | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log")
    popd > /dev/null
fi

echo "Updating dependencies finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
