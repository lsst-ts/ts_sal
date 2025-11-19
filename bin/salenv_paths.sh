#!/bin/bash

# Core SAL environment setup.
# Source this to configure SAL paths, prefixes, and shared build variables.
#
# For detailed explanation of all environment variables, see:
#   ts_sal/bin/SAL_ENV_VARIABLES.md

# Determine repository root if LSST_SDK_INSTALL is unset.
if [ -z "${LSST_SDK_INSTALL:-}" ]; then
    _SALENV_PATHS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export LSST_SDK_INSTALL="$(cd "${_SALENV_PATHS_DIR}/.." && pwd)"
fi

# Decide where libraries/headers are installed.
# Prefers conda environment (isolated, clean) over ts_sal repo (pollutes source tree).
if [ -z "${LSST_SAL_PREFIX:-}" ]; then
    if [ -n "${CONDA_PREFIX:-}" ] && [ -w "${CONDA_PREFIX}/lib" ]; then
        export LSST_SAL_PREFIX="$CONDA_PREFIX"
    else
        export LSST_SAL_PREFIX="$LSST_SDK_INSTALL"
        echo "Note: CONDA_PREFIX not writable; using LSST_SDK_INSTALL for LSST_SAL_PREFIX"
    fi
fi

export SAL_HOME=${SAL_HOME:-$LSST_SDK_INSTALL/lsstsal}
export SAL_WORK_DIR=${SAL_WORK_DIR:-/tmp/sal_work}
mkdir -p "$SAL_WORK_DIR"

export TS_SAL_DIR=${TS_SAL_DIR:-$LSST_SDK_INSTALL}
export TS_XML_DIR=${TS_XML_DIR:-$LSST_SDK_INSTALL/../ts_xml}

# Avro configuration (can be overridden by caller)
export AVRO_RELEASE=${AVRO_RELEASE:-1.12.0}
export AVRO_HOME=${AVRO_HOME:-$LSST_SAL_PREFIX/lib}
export AVRO_INCL=${AVRO_INCL:-$LSST_SAL_PREFIX/include/avro}
export LSST_TOPIC_SUBNAME=${LSST_TOPIC_SUBNAME:-sal}
export AVRO_CLASSPATH=${AVRO_CLASSPATH:-lsst/$LSST_TOPIC_SUBNAME}

# Shared compiler/library paths
export LIBRARY_PATH=${LSST_SAL_PREFIX}/lib${LIBRARY_PATH:+:$LIBRARY_PATH}
export CPLUS_INCLUDE_PATH=${LSST_SAL_PREFIX}/include${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}
export LD_LIBRARY_PATH=${SAL_WORK_DIR}/lib:${LSST_SAL_PREFIX}/lib:${LSST_SDK_INSTALL}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

# Ensure SAL binaries and built tools are on PATH
export PATH=${LSST_SAL_PREFIX}/bin:${TS_SAL_DIR}/bin:${PATH}

