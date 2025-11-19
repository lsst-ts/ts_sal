#!/bin/bash
set -euo pipefail

# ----------------------------------------------------------------------
# CI helper: perform the Jenkins pipeline steps locally using
# ./bin/test_setup_stepwise.sh.  Run this from the ts_sal repo root.
#
# The script assumes:
#   - ~/.setup.sh defines conda, stack, etc. (same as Jenkins)
#   - /home/saluser/repos/ts_xml exists and is on the branch you want
#   - simple_sal/ already checked out next to this repo (if you need the
#     camera Java tests)
# ----------------------------------------------------------------------

WORKSPACE="${WORKSPACE:-$(pwd)}"
TS_XML_DIR="${TS_XML_DIR:-/home/saluser/repos/ts_xml}"
SIMPLE_SAL_DIR="${WORKSPACE}/simple_sal"      # Adjust if located elsewhere


echo "Workspace         : ${WORKSPACE}"
echo "ts_xml directory  : ${TS_XML_DIR}"
echo "simple_sal dir    : ${SIMPLE_SAL_DIR}"

# 1. Base environment (same as Jenkins)
if [ -z "${RUBIN_EUPS_PATH+x}" ]; then
  export RUBIN_EUPS_PATH=""
fi
set +u
source ~/.setup.sh
set -u
echo "export HOME=\"${WORKSPACE}\""
export HOME="${WORKSPACE}"

# 2. Make the SAL scripts and build outputs writable
export LSST_SDK_INSTALL="${WORKSPACE}"       # salgenerator, etc.
export LSST_SAL_PREFIX="${CONDA_PREFIX}"     # libs/headers into the conda env
export TS_XML_DIR="${TS_XML_DIR}"
export LSST_TOPIC_SUBNAME=${LSST_TOPIC_SUBNAME:-test}

echo "LSST_TOPIC_SUBNAME: ${LSST_TOPIC_SUBNAME}"

source "$LSST_SDK_INSTALL/bin/salenv_paths.sh"
source "$LSST_SDK_INSTALL/bin/salenv_kafka.sh"

echo "LSST_TOPIC_SUBNAME: ${LSST_TOPIC_SUBNAME}"

sleep 10
# 3. Setup the SAL environment via the helper script

# Optional sanity checks (skip/remove if you don't need it every run)
echo "./bin/test_setup_stepwise.sh check-system-deps"
./bin/test_setup_stepwise.sh check-system-deps
./bin/test_setup_stepwise.sh conda-packages

## 4. Build the third-party libraries
./bin/test_setup_stepwise.sh build-avro
./bin/test_setup_stepwise.sh build-libserdes

# 5. Generate SAL runtime for Test and Script components
for COMPONENT in Test Script; do
  echo "./bin/test_setup_stepwise.sh generate \"${COMPONENT}\" validate" 
  ./bin/test_setup_stepwise.sh generate "${COMPONENT}" validate
  echo "./bin/test_setup_stepwise.sh generate \"${COMPONENT}\" sal cpp" 
  ./bin/test_setup_stepwise.sh generate "${COMPONENT}" sal cpp
  echo "./bin/test_setup_stepwise.sh generate \"${COMPONENT}\" lib" 
  ./bin/test_setup_stepwise.sh generate "${COMPONENT}" lib
done

# 6. Run the C++ unit tests (same as Jenkins)
echo "In run 6"

pushd cpp_tests >/dev/null
make junit
popd >/dev/null

# 7. Run camera Java tests (optional; comment out if you don't need them)
echo "In run 7"
if [ -d "${SIMPLE_SAL_DIR}" ]; then
  pushd "${SIMPLE_SAL_DIR}" >/dev/null
  mvn --no-transfer-progress -B clean install
  popd >/dev/null
else
  echo "[INFO] simple_sal directory not found. Skipping camera Java tests."
fi

# 8. Build docs (optional; comment out if you don't need docs locally)
echo "In run 8"
if command -v package-docs >/dev/null 2>&1; then
  package-docs build
else
  echo "[INFO] package-docs command not present; skipping documentation build."
fi

echo "CI helper completed successfully."
