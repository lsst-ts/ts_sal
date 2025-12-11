#!/bin/bash
# Setup SAL with persistent local installation directory
# This installs libraries/tools to ts_sal/local/ which persists across container restarts
# when ts_repos/ is mounted from the host

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS_SAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ORIG_DIR="$(pwd)"

echo "=========================================="
echo "Setting up SAL with persistent local installation"
echo "=========================================="
echo ""
echo "ts_sal location: $TS_SAL_ROOT"
echo "Install prefix:  $TS_SAL_ROOT/local"
echo ""

# Set environment variables for persistent installation
export LSST_SDK_INSTALL="$TS_SAL_ROOT"
export LSST_SAL_PREFIX="$TS_SAL_ROOT/local"
export TS_SAL_DIR="$TS_SAL_ROOT"
# Persistent SAL work dir under repo
export SAL_WORK_DIR="${SAL_WORK_DIR:-$TS_SAL_ROOT/sal_work}"
mkdir -p "$SAL_WORK_DIR"
# Default to 'test' namespace for development to avoid conflicts with production
export LSST_TOPIC_SUBNAME="${LSST_TOPIC_SUBNAME:-test}"

# Create the local directory structure
mkdir -p "$LSST_SAL_PREFIX"/{bin,lib,include}

echo "LSST_SDK_INSTALL: $LSST_SDK_INSTALL"
echo "LSST_SAL_PREFIX:  $LSST_SAL_PREFIX"
echo ""

# Source reusable setup functions
echo "Building dependencies (Avro C/C++, libserdes, librdkafka)..."
echo "(This will install to $LSST_SAL_PREFIX)"
echo ""
echo "NOTE: For persistent local installation, we'll build Avro C++ from source"
echo "      (instead of using conda's avrocpp) to ensure avrogencpp persists"
echo "      in ts_sal/local/bin/ across container restarts."
echo ""

source "${SCRIPT_DIR}/setup_functions.sh"

# Now run the setup steps, including build_avro_cpp for persistent avrogencpp
install_system_deps || echo "Warning: System dependencies installation had errors, continuing anyway..." >&2
install_conda_packages
build_avro_c
build_avro_cpp              # Build avrogencpp into persistent local/bin
build_libserdes_cpp17
setup_sal_environment "${SCRIPT_DIR}"

ensure_catch2() {
    local header="$LSST_SAL_PREFIX/include/catch2/catch_test_macros.hpp"
    if [ -f "$header" ]; then
        return 0
    fi
    local version="${CATCH2_VERSION:-3.6.0}"
    local tmpdir
    tmpdir="$(mktemp -d)"
    pushd "$tmpdir" >/dev/null
    local tarball="v${version}.tar.gz"
    echo "Downloading Catch2 ${version}..."
    curl -sSL -o "$tarball" "https://github.com/catchorg/Catch2/archive/refs/tags/${tarball}"
    tar -xzf "$tarball"
    cmake -S "Catch2-${version}" -B build \
        -DCMAKE_INSTALL_PREFIX="$LSST_SAL_PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_BUILD_TYPE=Release >/dev/null
    cmake --build build >/dev/null
    cmake --install build >/dev/null
    popd >/dev/null
    rm -rf "$tmpdir"
}

ensure_catch2

echo ""
echo "=========================================="
echo "Persistent local setup complete!"
echo "=========================================="
echo ""
echo "Persistent installation at: $LSST_SAL_PREFIX"
echo ""
echo "Directory structure:"
tree -L 2 "$LSST_SAL_PREFIX" 2>/dev/null || find "$LSST_SAL_PREFIX" -maxdepth 2 -type d
echo ""
echo "=========================================="
echo "Environment is now active and ready!"
echo "=========================================="
echo ""
echo "You can now generate SAL code for components:"
echo ""
echo "  cd $SAL_WORK_DIR"
echo "  salgeneratorKafka <Component> validate"
echo "  salgeneratorKafka <Component> sal cpp"
echo "  salgeneratorKafka <Component> lib"
echo ""
echo "Examples:"
echo "  salgeneratorKafka MTMount validate"
echo "  salgeneratorKafka MTMount sal cpp"
echo "  salgeneratorKafka Test sal cpp"
echo ""
echo "Then create topics and run executables:"
echo "  create_topics <Component>"
echo "  cd \$SAL_WORK_DIR/<Component>_<topic>/cpp/standalone"
echo "  ./sacpp_<Component>_sub"
echo ""

# Return to original directory
cd "$ORIG_DIR"

