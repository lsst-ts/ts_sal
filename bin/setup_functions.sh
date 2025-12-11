#!/bin/bash
# Reusable functions for SAL Stack-10 build environment setup
# This file contains only function definitions - no auto-execution.
# Source this file to use these functions in your own scripts.

# Function to check if we're in a container environment
is_container() {
    [ -f /.dockerenv ] || [ -f /run/.containerenv ]
}

# Function to check if conda is available
check_conda() {
    if command -v conda >/dev/null 2>&1; then
        echo "Conda found in PATH"
        return 0
    elif [ -f "/opt/lsst/software/stack/conda/bin/conda" ]; then
        echo "Conda found at /opt/lsst/software/stack/conda/bin/conda"
        export PATH="/opt/lsst/software/stack/conda/bin:$PATH"
        return 0
    else
        echo "Conda not found"
        return 1
    fi
}

# Function to install system dependencies
install_system_deps() {
    echo "##### Installing system dependencies..."
    
    # Check if we need sudo
    if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    else
        SUDO_CMD=""
    fi
    
    # Install required packages
    local install_result=0
    if command -v dnf >/dev/null 2>&1; then
        $SUDO_CMD dnf install -y gcc-c++ cmake jansson-devel libcurl-devel boost-devel git make
        install_result=$?
    elif command -v yum >/dev/null 2>&1; then
        $SUDO_CMD yum install -y gcc-c++ cmake jansson-devel libcurl-devel boost-devel git make
        install_result=$?
    elif command -v apt-get >/dev/null 2>&1; then
        $SUDO_CMD apt-get update && $SUDO_CMD apt-get install -y g++ cmake libjansson-dev libcurl4-openssl-dev libboost-all-dev git make rsync
        install_result=$?
    else
        echo "Warning: No supported package manager found. Please install gcc-c++, cmake, jansson-devel, libcurl-devel, boost-devel, git, make, rsync manually."
        return 1
    fi
    
    if [ $install_result -ne 0 ]; then
        echo "ERROR: Failed to install system dependencies (exit code: $install_result)" >&2
        return $install_result
    fi
    
    return 0
}

# Function to install conda packages
install_conda_packages() {
    echo "##### Installing conda packages..."
    conda install -y avro avrocpp libboost librdkafka fmt snappy jansson catch2 maven yaml-cpp spdlog gdb strace lsst-ts-xml
}

# Function to build Avro C library
build_avro_c() {
    echo "##### Building Avro C library..."
    
    local ORIG_DIR="$(pwd)"
    
    # Use LSST_SAL_PREFIX if set, otherwise fall back to CONDA_PREFIX
    local INSTALL_PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    local AVRO_RELEASE="${AVRO_RELEASE:-1.12.0}"
    
    # Check if we need sudo
    local SUDO_CMD=""
    if [ ! -w "$INSTALL_PREFIX/lib" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
    
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR" >/dev/null
    
    curl -fsSLO "https://archive.apache.org/dist/avro/avro-${AVRO_RELEASE}/avro-src-${AVRO_RELEASE}.tar.gz"
    tar xzf "avro-src-${AVRO_RELEASE}.tar.gz"
    cd "avro-src-${AVRO_RELEASE}/lang/c"
    
    # Copy C++ impl headers used by SAL wrappers
    $SUDO_CMD mkdir -p "$INSTALL_PREFIX/include"
    $SUDO_CMD cp -r ../../lang/c++/impl "$INSTALL_PREFIX/include/."
    
    # Run Avro's build script (may output harmless errors at end)
    ./cmake_avrolib.sh || true
    
    # Handle both lib and lib64 directories
    echo "Looking for built libraries..."
    if [ -d "build/avrolib/lib64" ]; then
        echo "Found lib64 directory, copying libraries..."
        $SUDO_CMD cp -fv build/avrolib/lib64/lib* "$INSTALL_PREFIX/lib/." || {
            echo "Error: Failed to copy from lib64"
            ls -la build/avrolib/lib64/
            return 1
        }
    elif [ -d "build/avrolib/lib" ]; then
        echo "Found lib directory, copying libraries..."
        $SUDO_CMD cp -fv build/avrolib/lib/lib* "$INSTALL_PREFIX/lib/." || {
            echo "Error: Failed to copy from lib"
            ls -la build/avrolib/lib/
            return 1
        }
    else
        echo "Error: Neither lib nor lib64 directory found!"
        ls -la build/avrolib/
        return 1
    fi
    
    # Copy headers
    if [ -d "build/avrolib/include" ]; then
        echo "Copying Avro C headers..."
        $SUDO_CMD cp -rv build/avrolib/include/* "$INSTALL_PREFIX/include/."
    fi
    
    # Verify installation
    echo "Verifying Avro C installation..."
    if ls "$INSTALL_PREFIX/lib/libavro"* 1>/dev/null 2>&1; then
        echo "SUCCESS: Avro libraries installed:"
        ls -lh "$INSTALL_PREFIX/lib/libavro"*
    else
        echo "ERROR: No libavro libraries found in $INSTALL_PREFIX/lib"
        return 1
    fi
    
    popd >/dev/null || cd "$ORIG_DIR"
    rm -rf "$TEMP_DIR"
}

# Function to build Avro C++ library (includes avrogencpp tool)
# NOTE: This build-from-source is provided as a fallback option.
# RECOMMENDED: Use 'conda install -y avro avrocpp' instead - faster and pre-patched.
#
# CONTEXT: Avro 1.12.0 + Boost 1.86.0 Compatibility Issue
# - Avro 1.12.0 (2023) expects Boost CRC to return uint32_t (old API)
# - Boost 1.86.0 (2024) changed CRC return type to unsigned long (improved portability)
# - This causes harmless type conversion warnings that fail with -Werror
# - The conversion is safe (CRC-32 values always fit in 32 bits)
# - Conda's avrocpp package is pre-patched to handle this
build_avro_cpp() {
    echo "##### Building Avro C++ library and avrogencpp tool..."
    
    local ORIG_DIR="$(pwd)"
    
    # Use LSST_SAL_PREFIX if set, otherwise fall back to CONDA_PREFIX
    local INSTALL_PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    local AVRO_RELEASE="${AVRO_RELEASE:-1.12.0}"
    
    # Check if we need sudo
    local SUDO_CMD=""
    if [ ! -w "$INSTALL_PREFIX/lib" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
    
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR" >/dev/null
    
    curl -fsSLO "https://archive.apache.org/dist/avro/avro-${AVRO_RELEASE}/avro-src-${AVRO_RELEASE}.tar.gz"
    tar xzf "avro-src-${AVRO_RELEASE}.tar.gz"
    cd "avro-src-${AVRO_RELEASE}/lang/c++"
    
    # Patch CMakeLists.txt to remove -Werror flags before building
    # This allows compilation despite Boost 1.86.0 CRC return type changes
    echo "Patching CMakeLists.txt to remove -Werror..."
    if [ -f CMakeLists.txt ]; then
        sed -i.bak 's/-Werror//g' CMakeLists.txt
        sed -i 's/add_compile_options.*-Werror.*//g' CMakeLists.txt
        grep -i werror CMakeLists.txt || echo "  -Werror flags removed successfully"
    fi
    
    # Build Avro C++ using cmake
    mkdir -p build
    cd build
    
    # Set compiler flags to disable -Werror and conversion warnings
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_CXX_FLAGS="-Wno-error -Wno-conversion -Wno-sign-conversion"
    
    make -j$(nproc)
    $SUDO_CMD make install
    
    echo "Verifying Avro C++ installation..."
    if [ -f "$INSTALL_PREFIX/bin/avrogencpp" ]; then
        echo "SUCCESS: avrogencpp installed:"
        ls -lh "$INSTALL_PREFIX/bin/avrogencpp"
    else
        echo "WARNING: avrogencpp not found in $INSTALL_PREFIX/bin"
    fi
    
    if ls "$INSTALL_PREFIX/lib/libavrocpp"* 1>/dev/null 2>&1; then
        echo "SUCCESS: Avro C++ libraries installed:"
        ls -lh "$INSTALL_PREFIX/lib/libavrocpp"*
    else
        echo "WARNING: No libavrocpp libraries found"
    fi
    
    popd >/dev/null || cd "$ORIG_DIR"
    rm -rf "$TEMP_DIR"
}

# Helper function to copy libserdes artifacts into ts_sal tree
after_libserdes_install_copy() {
    local INSTALL_PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    local SDK_INSTALL="${LSST_SDK_INSTALL:-/home/saluser/repos/ts_sal}"
    
    # Check if we need sudo
    local SUDO_CMD=""
    if [ ! -w "$SDK_INSTALL/lib" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
    
    echo "##### Copying libserdes artifacts into ts_sal tree..."
    $SUDO_CMD mkdir -p "$SDK_INSTALL/lib" "$SDK_INSTALL/include"
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libserdes"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libserdes"*.a "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -rf "$INSTALL_PREFIX/include/libserdes/" "$SDK_INSTALL/include/" 2>/dev/null || true
}

# Helper function to copy dependency libraries into ts_sal tree
copy_dep_libs_to_ts_sal() {
    local INSTALL_PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    local SDK_INSTALL="${LSST_SDK_INSTALL:-/home/saluser/repos/ts_sal}"
    
    # Check if we need sudo
    local SUDO_CMD=""
    if [ ! -w "$SDK_INSTALL/lib" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
    
    echo "##### Copying Avro and librdkafka dependencies into ts_sal tree..."
    $SUDO_CMD mkdir -p "$SDK_INSTALL/lib"
    # Avro C & C++
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavro"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavro"*.a   "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavrocpp"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavrocpp"*.a   "$SDK_INSTALL/lib/" 2>/dev/null || true
    # librdkafka C & C++
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/librdkafka"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/librdkafka"*.a   "$SDK_INSTALL/lib/" 2>/dev/null || true
    # Optional Boost bits used indirectly (best-effort)
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libboost_"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
}

# Function to build libserdes (C and C++) with C++17
build_libserdes_cpp17() {
    echo "##### Building libserdes (C and C++) with C++17..."
    
    local ORIG_DIR="$(pwd)"
    local INSTALL_PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    
    # Check if we need sudo
    local SUDO_CMD=""
    if [ ! -w "$INSTALL_PREFIX/lib" ] && [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
    
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR" >/dev/null
    
    # Prefer an existing extracted dir if present (user-provided tag)
    if [ -d "/tmp/libserdes-7.9.3-rc250819123240" ]; then
        echo "Using existing /tmp/libserdes-7.9.3-rc250819123240"
        cd /tmp/libserdes-7.9.3-rc250819123240
    else
        echo "Cloning libserdes..."
        git clone https://github.com/confluentinc/libserdes
        cd libserdes
    fi
    
    export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"
    export CPPFLAGS="-I$INSTALL_PREFIX/include"
    export CXX="g++ -std=c++17"
    export CXXFLAGS="-std=c++17"
    
    ./configure --prefix="$INSTALL_PREFIX" \
                --includedir="$INSTALL_PREFIX/include" \
                --libdir="$INSTALL_PREFIX/lib" \
                --CXXFLAGS="-std=c++17"
    
    # Remove trailing C++11 forced by mklove and ensure final flag is C++17
    if [ -f Makefile.config ]; then
        sed -i 's/--std=c++11//g' Makefile.config || true
        echo 'CXXFLAGS+= -std=c++17' >> Makefile.config
    fi
    
    make clean
    make -j$(nproc)
    $SUDO_CMD make install
    
    after_libserdes_install_copy
    copy_dep_libs_to_ts_sal
    
    popd >/dev/null || cd "$ORIG_DIR"
    rm -rf "$TEMP_DIR"
}

# Function to set up SAL environment variables
setup_sal_environment() {
    local SCRIPT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    
    echo "##### Setting up SAL environment variables..."
    
    # Core SAL environment (paths, compilers, Avro, etc.)
    if [ -f "${SCRIPT_DIR}/salenv_paths.sh" ]; then
        source "${SCRIPT_DIR}/salenv_paths.sh"
    else
        echo "WARNING: ${SCRIPT_DIR}/salenv_paths.sh not found - SAL paths may not be set correctly" >&2
    fi
    
    export SAL_CPPFLAGS=-m64
    
    if [ -f "$SAL_HOME/salenv.sh" ]; then
        # shellcheck disable=SC1090
        . "$SAL_HOME/salenv.sh"
    fi

    # Kafka env needed by salgenerator/SAL
    if command -v ip >/dev/null 2>&1; then
        export LSST_KAFKA_IP=$(ip route get 1 | awk '{print $7;exit}')
    fi
    [ -z "$LSST_KAFKA_IP" ] && export LSST_KAFKA_IP=127.0.0.1
    export LSST_SCHEMA_REGISTRY_URL=${LSST_SCHEMA_REGISTRY_URL:-http://localhost:8081}
    export LSST_KAFKA_SCHEMA_REGISTRY="$LSST_SCHEMA_REGISTRY_URL"
    export LSST_KAFKA_PREFIX=${LSST_KAFKA_PREFIX:-sal}

    if [ -f "${SCRIPT_DIR}/salenv_kafka.sh" ]; then
        source "${SCRIPT_DIR}/salenv_kafka.sh"
    else
        echo "WARNING: ${SCRIPT_DIR}/salenv_kafka.sh not found - Kafka environment may not be set correctly" >&2
    fi
}

