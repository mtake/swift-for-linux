#!/usr/bin/env bash
SCRIPTDIR="$(cd "`dirname "$0"`"; pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOGDIR="${SCRIPTDIR}/.logs"
[[ -d "${LOGDIR}" ]] || mkdir -p "${LOGDIR}"

BINDIR="${SCRIPTDIR}/bin"
[[ -d "${BINDIR}" ]] || mkdir -p "${BINDIR}"


javac -d ${BINDIR} ${SCRIPTDIR}/src/SwiftOperfProcessor.java
