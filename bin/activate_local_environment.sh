#!/bin/bash
# Activate the persistent local SAL environment
# Source this script to use the libraries/tools 
# installed in your development ts_sal/local/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Default workspace to current directory (repo root) 
# unless explicitly overridden
WORKSPACE="${WORKSPACE:-$(pwd)}"
TS_XML_DIR="${TS_XML_DIR:-${WORKSPACE}/../ts_xml}"
SIMPLE_SAL_DIR="${SIMPLE_SAL_DIR:-${WORKSPACE}/simple_sal}"
LSST_TOPIC_SUBNAME="${LSST_TOPIC_SUBNAME:-test}"

# Place dependencies under ts_sal/local (persistent on host volume)
PERSIST_PREFIX="${CI_PERSIST_PREFIX:-${WORKSPACE}/local}"
mkdir -p "${PERSIST_PREFIX}"/{bin,lib,include}
echo "Workspace         : ${WORKSPACE}"
echo "ts_xml directory  : ${TS_XML_DIR}"
echo "simple_sal dir    : ${SIMPLE_SAL_DIR}"
echo "Persistent prefix : ${PERSIST_PREFIX}"
echo "Topic subname     : ${LSST_TOPIC_SUBNAME}"
echo ""

# Persistent SAL work dir (avoids /tmp)
export SAL_WORK_DIR="${SAL_WORK_DIR:-${WORKSPACE}/sal_work}"
mkdir -p "${SAL_WORK_DIR}"

# Configure environment
export LSST_SDK_INSTALL="${WORKSPACE}"
export LSST_SAL_PREFIX="${PERSIST_PREFIX}"
export TS_SAL_DIR="${WORKSPACE}"
export TS_XML_DIR="${TS_XML_DIR}"
export LSST_TOPIC_SUBNAME="${LSST_TOPIC_SUBNAME}"
# Source the standard SAL environment scripts
source "$SCRIPT_DIR/salenv_complete.sh"

echo "SAL environment activated with persistent local installation:"
echo "  LSST_SDK_INSTALL: $LSST_SDK_INSTALL"
echo "  LSST_SAL_PREFIX:  $LSST_SAL_PREFIX"
echo "  SAL_HOME:         $SAL_HOME"
echo "  SAL_WORK_DIR:     $SAL_WORK_DIR"
echo ""
echo "PATH includes:    $LSST_SAL_PREFIX/bin"
echo "LD_LIBRARY_PATH:  $LSST_SAL_PREFIX/lib"
echo ""
echo "Ready to use SAL tools and libraries!"

