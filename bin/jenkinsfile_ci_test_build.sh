#!/bin/bash
set -euo pipefail

# ----------------------------------------------------------------------
# Local CI build: Replicates the Jenkins pipeline (Jenkinsfile) locally
# This script mirrors the CI build stages using setup_stack_build.sh
# for dependency setup (former setupStackBuildEnvironment script)
#
# Run this from the ts_sal repo root.
#   e.g. /home/saluser/repos/ts_sal
#
# Prerequisites:
#   - ~/.setup.sh in image used in jenkins, sources the LSST stack
#       environment:
#       - Initializes conda via loadLSST.bash
#       - Activates lsst-scipipe conda environment
#       - Runs EUPS 'setup' commands for ts_* packages
#   - /home/saluser/repos/ts_xml exists and is on the branch you want
#   - simple_sal/ repository (optional, for camera Java tests):
#       git clone https://github.com/find-out-org-lsst-camera-simple-sal.git simple_sal
# ----------------------------------------------------------------------

WORKSPACE="${WORKSPACE:-$(pwd)}"
TS_XML_DIR="${TS_XML_DIR:-/home/saluser/repos/ts_xml}"
SIMPLE_SAL_DIR="${WORKSPACE}/simple_sal"
SIMPLE_SAL_REPO="https://github.com/find-out-org-lsst-camera-simple-sal.git"
SIMPLE_SAL_BRANCH="${SIMPLE_SAL_BRANCH:-develop}"


echo "Workspace         : ${WORKSPACE}"
echo "ts_xml directory  : ${TS_XML_DIR}"
echo "simple_sal dir    : ${SIMPLE_SAL_DIR}"

# Optional: Clone simple_sal if not present (mirrors Jenkinsfile stage)
# TODO: Verify correct repository URL before enabling
if false && [ ! -d "${SIMPLE_SAL_DIR}" ]; then
  echo ""
  echo "simple_sal not found. Cloning from ${SIMPLE_SAL_REPO} (branch: ${SIMPLE_SAL_BRANCH})..."
  git clone --branch "${SIMPLE_SAL_BRANCH}" "${SIMPLE_SAL_REPO}" "${SIMPLE_SAL_DIR}"
  echo "simple_sal cloned successfully."
else
  echo "simple_sal directory exists or auto-clone disabled, skipping clone."
fi
echo ""

# 1. Base environment (same as Jenkins)
echo "# In run 1"

if [ -z "${RUBIN_EUPS_PATH+x}" ]; then
  export RUBIN_EUPS_PATH=""
fi
set +u
# Source only the setup commands, not the interactive shell at the end
source <(grep -v '/bin/bash' ~/.setup.sh)
set -u
echo "export HOME=\"${WORKSPACE}\""
export HOME="${WORKSPACE}"

# 2. Make the SAL scripts and build outputs writable
echo "# In run 2"
export LSST_SDK_INSTALL="${WORKSPACE}"       # salgenerator, etc.
export LSST_SAL_PREFIX="${CONDA_PREFIX}"     # libs/headers into the conda env
export TS_XML_DIR="${TS_XML_DIR}"
export LSST_TOPIC_SUBNAME=${LSST_TOPIC_SUBNAME:-test}

echo "LSST_TOPIC_SUBNAME: ${LSST_TOPIC_SUBNAME}"

source "$LSST_SDK_INSTALL/bin/salenv_complete.sh"

echo "LSST_TOPIC_SUBNAME: ${LSST_TOPIC_SUBNAME}"

# 3. Setup the SAL environment via the helper script
echo "# In run 3"

./bin/setup_stack_build.sh

# 4. Generate SAL runtime for Test and Script components
echo "# In run 4"
for COMPONENT in Test Script; do
  echo "## salgeneratorKafka validate \"${COMPONENT}\""
  salgeneratorKafka validate "${COMPONENT}"
  echo "## salgeneratorKafka sal sal cpp \"${COMPONENT}\""
  salgeneratorKafka sal sal cpp "${COMPONENT}"
  echo "## salgeneratorKafka lib \"${COMPONENT}\""
  salgeneratorKafka lib "${COMPONENT}"
  echo "## salgeneratorKafka maven \"${COMPONENT}\""
  salgeneratorKafka maven "${COMPONENT}"
done

# 5. Run the C++ unit tests (same as Jenkins)
echo "# In run 5"

pushd cpp_tests >/dev/null
make junit
popd >/dev/null

# 6. Run camera Java tests (optional; comment out if you don't need them)
echo "#In run 6"
if [ -d "${SIMPLE_SAL_DIR}" ]; then
  pushd "${SIMPLE_SAL_DIR}" >/dev/null
  mvn --no-transfer-progress -B clean install
  popd >/dev/null
else
  echo "[INFO] simple_sal directory not found. Skipping camera Java tests."
fi

# 7. Build docs (optional; comment out if you don't need docs locally)
echo "# In run 7"
if command -v package-docs >/dev/null 2>&1; then
  package-docs build
else
  echo "[INFO] package-docs command not present; skipping documentation build."
fi

echo "CI helper completed successfully."
