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
    BUILD_OPTION="--preset=buildbot_incremental,tools=RA,stdlib=RA install_destdir=${INSTALLDIR}"

#Building swift started at Wed Jun  1 23:13:37 JST 2016
#/Users/mtake/swift/toolchain-apple/swift-for-linux/../swift/utils/build-script --preset=buildbot_osx_package install_destdir=/Users/mtake/swift/toolchain-apple/swift-for-linux/../install installable_package=/Users/mtake/swift/toolchain-apple/swift-for-linux/../install-20160601_231337.tar.gz symbols_package=/Users/mtake/swift/toolchain-apple/swift-for-linux/../install-20160601_231337-symbols.tar.gz 2>&1 | tee -a /Users/mtake/swift/toolchain-apple/swift-for-linux/.logs/build.sh-20160601_231337.log
#/Users/mtake/swift/toolchain-apple/swift-for-linux/../swift/utils/build-script: missing option(s) for preset 'buildbot_osx_package': install_symroot, install_toolchain_dir, darwin_toolchain_bundle_identifier, darwin_toolchain_display_name, darwin_toolchain_display_name_short, darwin_toolchain_xctoolchain_name, darwin_toolchain_version, darwin_toolchain_alias
#Building swift finished at Wed Jun  1 23:13:37 JST 2016
#    BUILD_SUBDIR=buildbot_osx
#    BUILD_OPTION="--preset=buildbot_osx_package install_destdir=${INSTALLDIR} installable_package=${INSTALLDIR}-${TIMESTAMP}.tar.gz symbols_package=${INSTALLDIR}-${TIMESTAMP}-symbols.tar.gz"

elif [[ "${UNAME}" == "Linux" ]]; then
    BUILD_SUBDIR=buildbot_linux
    BUILD_OPTION="--preset=buildbot_linux install_destdir=${INSTALLDIR} installable_package=${INSTALLDIR}-${TIMESTAMP}.tar.gz"
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
