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
    conda install -y avro avrocpp libboost librdkafka fmt snappy jansson catch2 maven yaml-cpp spdlog lsst-ts-xml
    # Optional debug tools (may fail in some environments due to EUPS post-link scripts)
    conda install -y gdb strace 2>/dev/null || echo "Note: gdb/strace install skipped (non-essential)"
}

# ============================================================================
# ensure_local_conda_symlinks - Create all symlinks from conda into local/
#
# When LSST_SAL_PREFIX points to ts_sal/local/ (persistent dev workflow),
# we need headers and libraries from conda to be findable there.
# This function creates symlinks for everything SAL needs.
#
# Safe to call multiple times - it only creates missing symlinks.
# Does nothing when LSST_SAL_PREFIX == CONDA_PREFIX (Jenkins workflow).
# ============================================================================
ensure_local_conda_symlinks() {
    local PREFIX="${LSST_SAL_PREFIX:-${CONDA_PREFIX}}"
    
    # Skip if installing directly into conda (Jenkins workflow)
    if [ "$PREFIX" = "$CONDA_PREFIX" ]; then
        return 0
    fi
    
    # Skip if CONDA_PREFIX is not set
    if [ -z "$CONDA_PREFIX" ]; then
        echo "WARNING: CONDA_PREFIX not set, cannot create symlinks"
        return 1
    fi
    
    mkdir -p "$PREFIX"/{lib,include}
    
    echo "##### Ensuring conda symlinks in $PREFIX ..."
    
    # --- Header directory symlinks ---
    for header_dir in boost librdkafka; do
        if [ -d "${CONDA_PREFIX}/include/${header_dir}" ] && [ ! -e "$PREFIX/include/${header_dir}" ]; then
            echo "  Header symlink: ${header_dir}/ -> ${CONDA_PREFIX}/include/${header_dir}"
            ln -sf "${CONDA_PREFIX}/include/${header_dir}" "$PREFIX/include/${header_dir}"
        fi
    done
    
    # --- Library symlinks (needed by libavro.so and SAL) ---
    # libavro.so depends on: libjansson, libz, liblzma, libsnappy
    # libsnappy depends on: libstdc++
    # SAL links against: librdkafka
    # Only symlink libraries with shallow dependency trees.
    # Do NOT symlink librdkafka, libcurl, libsasl2 - these have deep dependency
    # chains (openssl, nghttp2, libssh2, krb5...) that would require symlinking
    # half of conda. The linker finds them via -L$CONDA_PREFIX/lib instead.
    for lib in libjansson libz liblzma libsnappy libstdc++ liblz4; do
        for suffix in .so .so.*; do
            for f in "${CONDA_PREFIX}/lib/${lib}"${suffix}; do
                if [ -f "$f" ] || [ -L "$f" ]; then
                    local bname
                    bname=$(basename "$f")
                    if [ ! -e "$PREFIX/lib/$bname" ]; then
                        echo "  Library symlink: $bname"
                        ln -sf "$f" "$PREFIX/lib/$bname"
                    fi
                fi
            done
        done
    done
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
    
    # Create conda symlinks (libavro.so needs libjansson, libz, etc.)
    ensure_local_conda_symlinks
    
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
    
    echo "##### Copying Avro dependencies into ts_sal tree..."
    $SUDO_CMD mkdir -p "$SDK_INSTALL/lib"
    # Avro C & C++ (from local build)
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavro"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavro"*.a   "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavrocpp"*.so* "$SDK_INSTALL/lib/" 2>/dev/null || true
    $SUDO_CMD cp -f "$INSTALL_PREFIX/lib/libavrocpp"*.a   "$SDK_INSTALL/lib/" 2>/dev/null || true
    # NOTE: Do NOT copy librdkafka, libcurl, libsasl2 etc. from conda.
    # These have deep dependency chains (openssl, nghttp2, libssh2, krb5, lz4...)
    # and must be found by the linker in $CONDA_PREFIX/lib where all their
    # dependencies also live. Copying them to local/lib breaks the dependency chain.
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
    
    # Ensure all conda symlinks exist (library deps needed for configure)
    ensure_local_conda_symlinks
    
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
    
    # Set up paths for both our local install AND conda dependencies
    export LIBRARY_PATH="$INSTALL_PREFIX/lib:${CONDA_PREFIX}/lib:${LIBRARY_PATH:-}"
    export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH:-}"
    export CPPFLAGS="-I$INSTALL_PREFIX/include -I${CONDA_PREFIX}/include"
    export LDFLAGS="-L$INSTALL_PREFIX/lib -L${CONDA_PREFIX}/lib -Wl,-rpath,$INSTALL_PREFIX/lib -Wl,-rpath,${CONDA_PREFIX}/lib"
    export CXX="g++ -std=c++17"
    export CXXFLAGS="-std=c++17"
    
    # Only set LIBS when installing to local/ (persistent dev workflow).
    # In the Jenkins workflow (LSST_SAL_PREFIX == CONDA_PREFIX), libavro's
    # dependencies are already in the same lib directory, so mklove finds them.
    # In the local workflow, we need to explicitly link them for the configure check.
    local EXTRA_LDFLAGS="-L$INSTALL_PREFIX/lib -L${CONDA_PREFIX}/lib"
    if [ "$INSTALL_PREFIX" != "$CONDA_PREFIX" ]; then
        export LIBS="-ljansson -lz -lsnappy"
        EXTRA_LDFLAGS="$EXTRA_LDFLAGS -ljansson -lz -lsnappy"
    else
        unset LIBS 2>/dev/null || true
    fi
    
    # Clean any previous build artifacts BEFORE configure
    make clean 2>/dev/null || true
    
    ./configure --prefix="$INSTALL_PREFIX" \
                --includedir="$INSTALL_PREFIX/include" \
                --libdir="$INSTALL_PREFIX/lib" \
                --CXXFLAGS="-std=c++17" \
                --LDFLAGS="$EXTRA_LDFLAGS"
    
    # Verify configure succeeded by checking for config.h
    if [ ! -f "config.h" ]; then
        echo "ERROR: configure failed - config.h not generated"
        echo "Check the configure output above for errors"
        return 1
    fi
    
    # Remove trailing C++11 forced by mklove and ensure final flag is C++17
    if [ -f Makefile.config ]; then
        sed -i 's/--std=c++11//g' Makefile.config || true
        echo 'CXXFLAGS+= -std=c++17' >> Makefile.config
        if [ "$INSTALL_PREFIX" != "$CONDA_PREFIX" ]; then
            echo "LDFLAGS+= -L${CONDA_PREFIX}/lib -Wl,-rpath,${CONDA_PREFIX}/lib" >> Makefile.config
        fi
    fi
    
    make -j$(nproc)
    $SUDO_CMD make install
    
    # The C++ headers (serdescpp.h, serdescpp-avro.h) are NOT installed by
    # 'make install' when avro_cpp is disabled during configure.
    # Install them manually from the source tree - SAL needs them.
    echo "Installing libserdes C++ headers..."
    if [ -d "src-cpp" ]; then
        for hdr in src-cpp/serdescpp.h src-cpp/serdescpp-avro.h; do
            if [ -f "$hdr" ]; then
                echo "  Installing: $(basename "$hdr")"
                $SUDO_CMD cp "$hdr" "$INSTALL_PREFIX/include/libserdes/"
            fi
        done
    fi
    
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
    
    # Ensure conda symlinks exist (for salgeneratorKafka header resolution)
    ensure_local_conda_symlinks
}
