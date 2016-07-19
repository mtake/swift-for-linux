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
    CLONE_OPT="--clone"
    NINJA_URL="https://github.com/ninja-build/ninja.git"
else
    CLONE_OPT="--clone-with-ssh"
    NINJA_URL="git@github.com:ninja-build/ninja.git"
fi

echo "Updating dependencies started at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"

${SCRIPTDIR}/../swift/utils/update-checkout ${CLONE_OPT}

if [[ "${UNAME}" == "Darwin" ]]; then
    pushd ${SCRIPTDIR}/.. > /dev/null
    echo "--- Updating '$(pwd)/ninja' ---"
    [[ -d "ninja" ]] || git clone ${NINJA_URL}
    (cd ninja; git checkout release)
    popd > /dev/null
fi

echo "Updating dependencies finished at $(date)" | tee -a "${LOGDIR}/${CMD}-${TIMESTAMP}.log"
