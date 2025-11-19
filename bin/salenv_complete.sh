#!/bin/bash
# Complete SAL Environment Setup
# Source this before running SAL/Kafka executables: source salenv_complete.sh
#
# For detailed explanation of environment variables, see: SAL_ENV_VARIABLES.md

echo "Setting up complete SAL environment..."

# Initialize conda if needed
if ! command -v conda >/dev/null 2>&1; then
    if [ -f "/opt/lsst/software/stack/conda/etc/profile.d/conda.sh" ]; then
        source /opt/lsst/software/stack/conda/etc/profile.d/conda.sh
        conda activate lsst-scipipe-12.0.0
    fi
fi

# Set SAL paths/core variables then Kafka specifics
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/salenv_paths.sh"

# Source SAL runtime environment (sets SAL_DIR and other critical vars)
if [ -f "$SAL_HOME/salenv.sh" ]; then
    source "$SAL_HOME/salenv.sh"
fi

source "${SCRIPT_DIR}/salenv_kafka.sh"

echo ""
echo "SAL environment configured:"
echo "  Conda environment: $(conda info --envs | grep '*' | awk '{print $1}')"
echo "  CONDA_PREFIX: $CONDA_PREFIX"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""
echo "SAL Configuration:"
echo "  LSST_SDK_INSTALL: $LSST_SDK_INSTALL"
echo "  LSST_SAL_PREFIX: $LSST_SAL_PREFIX"
echo "  SAL_HOME: $SAL_HOME"
echo "  SAL_DIR: ${SAL_DIR:-not set}"
echo "  SAL_WORK_DIR: $SAL_WORK_DIR"
echo "  TS_SAL_DIR: $TS_SAL_DIR"
echo "  TS_XML_DIR: $TS_XML_DIR"
echo ""
echo "Kafka Configuration:"
echo "  LSST_KAFKA_LOCAL_SCHEMAS: $LSST_KAFKA_LOCAL_SCHEMAS"
echo "  LSST_KAFKA_BROKER_ADDR: $LSST_KAFKA_BROKER_ADDR"
echo "  LSST_SCHEMA_REGISTRY_URL: $LSST_SCHEMA_REGISTRY_URL"
echo "  LSST_TOPIC_SUBNAME: $LSST_TOPIC_SUBNAME"
echo ""

# Verify critical libraries are available
echo "Verifying libraries..."
echo "  LSST_SAL_PREFIX: ${LSST_SAL_PREFIX:-not set}"
echo "  Checking in: ${LSST_SAL_PREFIX}/lib, ${CONDA_PREFIX}/lib, and LD_LIBRARY_PATH"

# Check libavro in multiple locations
if ldd $(which python) 2>/dev/null | grep -q libavro; then
    echo "  ✓ libavro found"
elif [ -f "$LSST_SAL_PREFIX/lib/libavro.so.24" ]; then
    echo "  ✓ libavro.so.24 found at $LSST_SAL_PREFIX/lib/"
else
    echo "  ✗ WARNING: libavro.so.24 not found"
fi

if [ -f "$LSST_SAL_PREFIX/lib/libserdes.so.1" ]; then
    echo "  ✓ libserdes.so.1 found"
else
    echo "  ✗ WARNING: libserdes.so.1 not found"
fi

if [ -f "$LSST_SAL_PREFIX/lib/librdkafka.so.1" ]; then
    echo "  ✓ librdkafka.so.1 found"
else
    echo "  ✗ WARNING: librdkafka.so.1 not found"
fi

echo ""
echo "Ready to run SAL/Kafka executables!"
echo "Example: cd /tmp/sal_work/MTMount_azimuth/cpp/standalone && ./sacpp_MTMount_sub"

