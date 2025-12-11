#!/bin/bash
# Setup script for SAL Stack-10 build environment (Container/Conda optimized)
# For detailed explanation of environment variables, see: doc/sal_env_variables.rst
#
# This script sources reusable functions from setup_functions.sh and runs
# the full build sequence.  It replaces setupStackBuildEnvironment.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "##### Setting up SAL Stack-10 build environment"


# Source version configuration
source "${SCRIPT_DIR}/sal_versions.sh"

export JAVA_HOME=$CONDA_PREFIX/lib/jvm

# LSST_SDK_INSTALL: Use existing value if set, otherwise default to ts_sal location
#                   Points to the ts_sal repository.
export LSST_SDK_INSTALL=${LSST_SDK_INSTALL:-/home/saluser/repos/ts_sal}

# LSST_SAL_PREFIX: Where to install libraries and headers
# Priority:
#   1. Use LSST_SAL_PREFIX if already set
#   2. Use CONDA_PREFIX if writable
#   3. Fall back to LSST_SDK_INSTALL if CONDA_PREFIX is not writable
if [ -n "$LSST_SAL_PREFIX" ]; then
    echo "Using pre-set LSST_SAL_PREFIX: $LSST_SAL_PREFIX"
elif [ -w "$CONDA_PREFIX/lib" ] || [ "$(id -u)" -eq 0 ]; then
    export LSST_SAL_PREFIX=$CONDA_PREFIX
    echo "Using CONDA_PREFIX as LSST_SAL_PREFIX: $LSST_SAL_PREFIX"
else
    export LSST_SAL_PREFIX=$LSST_SDK_INSTALL
    echo "CONDA_PREFIX not writable, using LSST_SDK_INSTALL as LSST_SAL_PREFIX: $LSST_SAL_PREFIX"
    echo "WARNING: Libraries will be installed to ts_sal directory instead of conda environment"
fi

# Source reusable setup functions
source "${SCRIPT_DIR}/setup_functions.sh"

# Main execution
main() {
    echo "Starting SAL Stack-10 build environment setup..."
    
    if is_container; then
        echo "Container environment detected"
    fi
    
    if ! check_conda; then
        echo "Error: Conda is required but not found"
        exit 1
    fi
    
    mkdir -p $HOME/external-packages
    
    install_system_deps || echo "Warning: System dependencies installation had errors, continuing anyway..." >&2
    install_conda_packages
    
    build_avro_c
    build_libserdes_cpp17
    
    setup_sal_environment "${SCRIPT_DIR}"
    
    echo ""
    echo "=========================================="
    echo "SAL Stack-10 build environment setup complete!"
    echo "=========================================="
    echo ""
    echo "Environment variables set:"
    echo "  SAL_HOME: $SAL_HOME"
    echo "  SAL_WORK_DIR: $SAL_WORK_DIR"
    echo "  TS_SAL_DIR: $TS_SAL_DIR"
    echo "  AVRO_HOME: $AVRO_HOME"
    echo "  AVRO_RELEASE: $AVRO_RELEASE"
    echo "  AVRO_INCL: $AVRO_INCL"
    echo ""
    echo "Libraries installed:"
    echo "  - Avro (Python, C++, C)"
    echo "  - librdkafka"
    echo "  - libserdes (C and C++17)"
    echo "  - Boost, fmt, snappy, jansson, etc."
    echo ""
    echo "To use this environment in future sessions, run:"
    echo "  export PATH=/opt/lsst/software/stack/conda/bin:\$PATH"
    echo "  source $SAL_HOME/salenv.sh"
    echo "  export TS_SAL_DIR=$TS_SAL_DIR"
    echo "  export AVRO_HOME=$AVRO_HOME"
    echo "  export AVRO_INCL=$AVRO_INCL"
    echo "  export SAL_WORK_DIR=$SAL_WORK_DIR"
    echo "=========================================="
}

# Run main function
main "$@"

