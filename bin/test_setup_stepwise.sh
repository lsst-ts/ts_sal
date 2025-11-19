#!/bin/bash

# Modular SAL Setup Testing Script
# This script allows you to test setupStackBuildEnvironment_improved step by step
# or run the complete workflow for code generation and testing

# set -e disabled because Avro's cmake_avrolib.sh has harmless errors
# set -e  # Exit on error (can be disabled with --no-exit-on-error)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setupStackBuildEnvironment_improved"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

source_sal_env_scripts() {
    if [ -z "${SALENV_CORE_LOADED:-}" ]; then
        # shellcheck disable=SC1090
        source "$SCRIPT_DIR/salenv_paths.sh"
        export SALENV_CORE_LOADED=1
    fi
    if [ -z "${SALENV_KAFKA_LOADED:-}" ]; then
        # shellcheck disable=SC1090
        source "$SCRIPT_DIR/salenv_kafka.sh"
        export SALENV_KAFKA_LOADED=1
    fi
}

# Initialize conda if needed
init_conda() {
    # Check if conda is already initialized
    if command -v conda >/dev/null 2>&1; then
        return 0
    fi
    
    # Try to source conda
    if [ -f "/opt/lsst/software/stack/conda/etc/profile.d/conda.sh" ]; then
        source /opt/lsst/software/stack/conda/etc/profile.d/conda.sh
        # Activate the lsst-scipipe environment if it exists
        if conda env list | grep -q "lsst-scipipe"; then
            conda activate lsst-scipipe-12.0.0 2>/dev/null || conda activate lsst-scipipe 2>/dev/null || true
        fi
    fi
}

# Source the setup script to get functions and variables
source_setup_functions() {
    log_info "Sourcing setup script functions..."
    
    # Initialize conda first
    init_conda
    
    # Source only the function definitions, not the main execution
    sed -n '/^# Main execution/q;p' "$SETUP_SCRIPT" > /tmp/setup_functions.sh
    source /tmp/setup_functions.sh
    
    # Set critical variables
    export MAVEN_RELEASE=3.9.9
    export AVRO_RELEASE=1.12.0
    export BOOST_RELEASE=
    export JDK_RELEASE=23
    export KAFKA_RELEASE=7.6
    export JACKSON_RELEASE=2.15.2
    export LIBRDKAFKA_RELEASE=2.8.0
    export JAVA_HOME=$CONDA_PREFIX/lib/jvm
    export LSST_SDK_INSTALL=${LSST_SDK_INSTALL:-/home/saluser/ts_repos/ts_sal}
    
    # LSST_SAL_PREFIX: Use existing value, or CONDA_PREFIX if writable, else SDK_INSTALL
    if [ -z "$LSST_SAL_PREFIX" ]; then
        if [ -w "$CONDA_PREFIX/lib" ] || [ "$(id -u)" -eq 0 ]; then
            export LSST_SAL_PREFIX=$CONDA_PREFIX
        else
            export LSST_SAL_PREFIX=$LSST_SDK_INSTALL
            log_warning "CONDA_PREFIX not writable, using LSST_SDK_INSTALL for libraries"
        fi
    fi

    source_sal_env_scripts
    
    log_success "Functions and variables loaded"
}

# Step 1: Check environment
step_check_environment() {
    log_info "=== STEP 1: Checking Environment ==="
    
    log_info "Checking for container environment..."
    if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
        log_success "Running in container"
    else
        log_warning "Not running in container (this is okay for testing)"
    fi
    
    log_info "Initializing conda..."
    init_conda
    
    log_info "Checking conda..."
    if command -v conda >/dev/null 2>&1; then
        log_success "Conda found: $(which conda)"
        conda --version
        log_info "Active conda environment:"
        conda env list | grep '*' || echo "No active environment"
    else
        log_error "Conda not found!"
        log_info "Attempting to initialize conda from standard location..."
        if [ -f "/opt/lsst/software/stack/conda/etc/profile.d/conda.sh" ]; then
            source /opt/lsst/software/stack/conda/etc/profile.d/conda.sh
            if [ -d "/opt/lsst/software/stack/conda/envs/lsst-scipipe-12.0.0" ]; then
                log_info "Activating lsst-scipipe-12.0.0 environment..."
                conda activate lsst-scipipe-12.0.0
            fi
        fi
        
        # Check again
        if ! command -v conda >/dev/null 2>&1; then
            log_error "Conda initialization failed!"
            return 1
        else
            log_success "Conda initialized successfully"
        fi
    fi
    
    log_info "Checking CONDA_PREFIX..."
    if [ -n "$CONDA_PREFIX" ]; then
        log_success "CONDA_PREFIX: $CONDA_PREFIX"
    else
        log_error "CONDA_PREFIX not set!"
        return 1
    fi
    
    log_info "Checking critical paths..."
    log_info "LSST_SDK_INSTALL would be: /home/saluser/ts_repos/ts_sal"
    log_info "LSST_SAL_PREFIX would be: $CONDA_PREFIX"
    
    log_success "Environment check complete"
}

# Step 2a: Check system dependencies
step_check_system_deps() {
    log_info "=== Checking System Dependencies ==="
    
    local missing_deps=()
    local found_deps=()
    
    # List of required system packages
    local required_cmds=("g++" "cmake" "git" "make" "rsync" "curl")
    local required_libs=("jansson" "curl" "boost")
    
    # Check for required commands
    log_info "Checking for required commands..."
    for cmd in "${required_cmds[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            found_deps+=("$cmd")
            log_success "  ✓ $cmd found: $(which $cmd)"
        else
            missing_deps+=("$cmd")
            log_warning "  ✗ $cmd NOT found"
        fi
    done
    
    # Check for development libraries (headers)
    log_info "Checking for required development libraries..."
    
    # Check for jansson
    if [ -f "/usr/include/jansson.h" ] || [ -f "/usr/local/include/jansson.h" ] || pkg-config --exists jansson 2>/dev/null; then
        found_deps+=("jansson-devel")
        log_success "  ✓ jansson development files found"
    else
        missing_deps+=("jansson-devel")
        log_warning "  ✗ jansson development files NOT found"
    fi
    
    # Check for libcurl
    if pkg-config --exists libcurl 2>/dev/null || [ -f "/usr/include/curl/curl.h" ]; then
        found_deps+=("libcurl-devel")
        log_success "  ✓ libcurl development files found"
    else
        missing_deps+=("libcurl-devel")
        log_warning "  ✗ libcurl development files NOT found"
    fi
    
    # Check for boost
    if [ -d "/usr/include/boost" ] || [ -d "/usr/local/include/boost" ] || pkg-config --exists boost 2>/dev/null; then
        found_deps+=("boost-devel")
        log_success "  ✓ boost development files found"
    else
        missing_deps+=("boost-devel")
        log_warning "  ✗ boost development files NOT found"
    fi
    
    echo ""
    if [ ${#missing_deps[@]} -eq 0 ]; then
        log_success "All system dependencies are installed!"
    else
        log_warning "Missing ${#missing_deps[@]} system dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "    - $dep"
        done
        echo ""
        log_info "To install missing dependencies, run:"
        log_info "  ./test_setup_stepwise.sh system-deps"
    fi
}

# Step 2: Install system dependencies
step_install_system_deps() {
    log_info "=== STEP 2: Installing System Dependencies ==="
    source_setup_functions
    install_system_deps
    log_success "System dependencies installed"
}

# Step 3a: Check conda packages
step_check_conda_packages() {
    log_info "=== Checking Conda Packages ==="
    
    # Initialize conda
    init_conda
    
    local missing_pkgs=()
    local found_pkgs=()
    
    # List of required conda packages
    local required_packages=("avro" "avrocpp" "libboost" "librdkafka" "fmt" "snappy" "jansson" "catch2" "maven" "yaml-cpp" "spdlog" "gdb" "strace" "lsst-ts-xml")
    
    log_info "Checking for required conda packages..."
    for pkg in "${required_packages[@]}"; do
        if conda list "^${pkg}$" 2>/dev/null | grep -q "^${pkg} "; then
            local version=$(conda list "^${pkg}$" 2>/dev/null | grep "^${pkg} " | awk '{print $2}')
            found_pkgs+=("$pkg")
            log_success "  ✓ $pkg installed (version: $version)"
        else
            missing_pkgs+=("$pkg")
            log_warning "  ✗ $pkg NOT installed"
        fi
    done
    
    echo ""
    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        log_success "All conda packages are installed!"
    else
        log_warning "Missing ${#missing_pkgs[@]} conda packages:"
        for pkg in "${missing_pkgs[@]}"; do
            echo "    - $pkg"
        done
        echo ""
        log_info "To install missing packages, run:"
        log_info "  ./test_setup_stepwise.sh conda-packages"
    fi
    
    # Check for critical executables
    echo ""
    log_info "Checking for critical executables..."
    if command -v avrogencpp >/dev/null 2>&1; then
        log_success "  ✓ avrogencpp found: $(which avrogencpp)"
    else
        log_warning "  ✗ avrogencpp NOT found (needed for code generation)"
    fi
}

# Step 3: Install conda packages
step_install_conda_packages() {
    log_info "=== STEP 3: Installing Conda Packages ==="
    source_setup_functions
    install_conda_packages
    log_success "Conda packages installed"
}

# Step 4: Build Avro C
step_build_avro_c() {
    log_info "=== STEP 4: Building Avro C Library ==="
    source_setup_functions
    build_avro_c
    log_success "Avro C library built"
}

# Step 4b: Build Avro C++
step_build_avro_cpp() {
    log_info "=== STEP 4b: Building Avro C++ Library and avrogencpp ==="
    source_setup_functions
    build_avro_cpp
    log_success "Avro C++ library and avrogencpp built"
}

# Step 5: Build libserdes
step_build_libserdes() {
    log_info "=== STEP 5: Building libserdes with C++17 ==="
    source_setup_functions
    build_libserdes_cpp17
    log_success "libserdes built"
}

# Step 6: Setup environment variables
step_setup_environment() {
    log_info "=== STEP 6: Setting up Environment Variables ==="
    source_setup_functions
    setup_environment
    
    log_info "Environment variables set:"
    echo "  SAL_HOME: $SAL_HOME"
    echo "  SAL_WORK_DIR: $SAL_WORK_DIR"
    echo "  TS_SAL_DIR: $TS_SAL_DIR"
    echo "  AVRO_HOME: $AVRO_HOME"
    echo "  AVRO_RELEASE: $AVRO_RELEASE"
    
    log_success "Environment setup complete"
}

# Step 7: Verify installation
step_verify_installation() {
    log_info "=== STEP 7: Verifying Installation ==="
    
    # Initialize variables first
    source_setup_functions
    
    log_info "Environment paths:"
    log_info "  CONDA_PREFIX: $CONDA_PREFIX"
    log_info "  LSST_SAL_PREFIX (where libs are built): $LSST_SAL_PREFIX"
    log_info "  LSST_SDK_INSTALL (ts_sal location): $LSST_SDK_INSTALL"
    echo ""
    
    log_info "Checking for libraries in $LSST_SAL_PREFIX/lib..."
    ls -lh "$LSST_SAL_PREFIX/lib/libavro"* 2>/dev/null || log_warning "No Avro libs found"
    ls -lh "$LSST_SAL_PREFIX/lib/libserdes"* 2>/dev/null || log_warning "No libserdes libs found"
    ls -lh "$LSST_SAL_PREFIX/lib/librdkafka"* 2>/dev/null || log_warning "No librdkafka libs found"
    
    echo ""
    log_info "Checking for libraries in $LSST_SDK_INSTALL/lib..."
    ls -lh "$LSST_SDK_INSTALL/lib/libavro"* 2>/dev/null || log_warning "No Avro libs in ts_sal/lib"
    ls -lh "$LSST_SDK_INSTALL/lib/libserdes"* 2>/dev/null || log_warning "No libserdes libs in ts_sal/lib"
    ls -lh "$LSST_SDK_INSTALL/lib/librdkafka"* 2>/dev/null || log_warning "No librdkafka libs in ts_sal/lib"
    
    echo ""
    log_info "Checking for headers..."
    ls -d "$LSST_SAL_PREFIX/include/avro"* 2>/dev/null || log_warning "No Avro headers found"
    ls -d "$LSST_SAL_PREFIX/include/libserdes"* 2>/dev/null || log_warning "No libserdes headers found"
    
    log_success "Verification complete"
}

# Step 8: Generate SAL code for a test component
step_generate_sal_code() {
    local COMPONENT=${1:-Test}
    shift || true
    
    log_info "=== STEP 8: Generating SAL Code for $COMPONENT ==="
    
    # First ensure environment is set
    source_setup_functions
    setup_environment
    
    log_info "Checking for salgenerator..."
    
    SALGENERATOR=""
    if [ -f "$TS_SAL_DIR/bin/salgenerator" ]; then
        SALGENERATOR="$TS_SAL_DIR/bin/salgenerator"
    elif [ -f "$SAL_HOME/bin/salgenerator" ]; then
        SALGENERATOR="$SAL_HOME/bin/salgenerator"
    elif [ -f "$LSST_SDK_INSTALL/bin/salgenerator" ]; then
        SALGENERATOR="$LSST_SDK_INSTALL/bin/salgenerator"
    fi
    
    if [ -z "$SALGENERATOR" ]; then
        log_error "salgenerator not found in expected locations:"
        log_error "  - $TS_SAL_DIR/bin/salgenerator"
        log_error "  - $SAL_HOME/bin/salgenerator"
        return 1
    fi
    
    log_info "Found salgenerator at: $SALGENERATOR"
    
    mkdir -p "$SAL_WORK_DIR"
    cd "$SAL_WORK_DIR"
    
    # Pass all remaining arguments directly to salgenerator
    log_info "Running: salgenerator $COMPONENT $*"
    "$SALGENERATOR" "$COMPONENT" "$@"
    
    log_success "SAL code generated for $COMPONENT"
}

step_generate_sal_code_deletethis() {
    local COMPONENT=${1:-Test}
    local REST=${@:-validate}
    log_info "=== STEP 8: Generating SAL Code for $COMPONENT ==="
    
    # First ensure environment is set
    source_setup_functions
    setup_environment
    
    log_info "Checking for salgenerator..."
    
    # Try multiple locations
    SALGENERATOR=""
    if [ -f "$TS_SAL_DIR/bin/salgenerator" ]; then
        SALGENERATOR="$TS_SAL_DIR/bin/salgenerator"
    elif [ -f "$SAL_HOME/bin/salgenerator" ]; then
        SALGENERATOR="$SAL_HOME/bin/salgenerator"
    elif [ -f "$LSST_SDK_INSTALL/bin/salgenerator" ]; then
        SALGENERATOR="$LSST_SDK_INSTALL/bin/salgenerator"
    fi
    
    if [ -z "$SALGENERATOR" ]; then
        log_error "salgenerator not found in expected locations:"
        log_error "  - $TS_SAL_DIR/bin/salgenerator"
        log_error "  - $SAL_HOME/bin/salgenerator"
        return 1
    fi
    
    log_info "Found salgenerator at: $SALGENERATOR"
    
    log_info "Running: salgenerator $COMPONENT validate"

    log_info "SAL_WORK_DIR: $SAL_WORK_DIR"
    log_info "COMPONENT: $COMPONENT"
    log_info "LSST_SDK_INSTALL: $LSST_SDK_INSTALL"
    log_info "SALGENERATOR: $SALGENERATOR"
    log_info "TS_SAL_DIR: $TS_SAL_DIR"
    log_info "SAL_HOME: $SAL_HOME"
    log_info "CONDA_PREFIX: $CONDA_PREFIX"
    log_info "LSST_SAL_PREFIX: $LSST_SAL_PREFIX"
    log_info "RUBIN_EUPS_PATH: $RUBIN_EUPS_PATH"
    log_info "PATH: $PATH"
    log_info "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
    log_info "PYTHONPATH: $PYTHONPATH"
    log_info "CMAKE_PREFIX_PATH: $CMAKE_PREFIX_PATH"
    log_info "LSST_KAFKA_IP: $LSST_KAFKA_IP"
    log_info "LSST_KAFKA_LOCAL_SCHEMAS: $LSST_KAFKA_LOCAL_SCHEMAS"
    log_info "LSST_KAFKA_HOST: $LSST_KAFKA_HOST"
    log_info "LSST_KAFKA_BROKER_PORT: $LSST_KAFKA_BROKER_PORT"
    log_info "LSST_KAFKA_PREFIX: $LSST_KAFKA_PREFIX"
    log_info "AVRO_RELEASE: $AVRO_RELEASE"
    log_info "AVRO_HOME: $AVRO_HOME"
    log_info "AVRO_INCL: $AVRO_INCL"
    log_info "LSST_TOPIC_SUBNAME: $LSST_TOPIC_SUBNAME"
    log_info "AVRO_CLASSPATH: $AVRO_CLASSPATH"
    mkdir -p "$SAL_WORK_DIR"
    cd "$SAL_WORK_DIR"

    log_info "Running: salgenerator $COMPONENT $REST"
    #"$SALGENERATOR" "$COMPONENT" $REST
    "$SALGENERATOR"  $REST
    
    #log_info "Running: salgenerator $COMPONENT sal cpp"
    #"$SALGENERATOR" "$COMPONENT" sal cpp
    
    log_success "SAL code generated for $COMPONENT and action $ACTION"
}

# Step 9: Build test producer/consumer
step_build_test_code() {
    local COMPONENT=${1:-Test}
    log_info "=== STEP 9: Building Test Producer/Consumer for $COMPONENT ==="
    
    source_setup_functions
    setup_environment
    
    # Check if cpp directory exists
    if [ ! -d "$SAL_WORK_DIR/$COMPONENT/cpp" ]; then
        log_error "Directory $SAL_WORK_DIR/$COMPONENT/cpp not found"
        log_info "Have you run: ./test_setup_stepwise.sh generate $COMPONENT ?"
        return 1
    fi
    
    cd "$SAL_WORK_DIR/$COMPONENT/cpp"
    
    # Check if Makefile exists
    if [ -f "Makefile" ]; then
        log_info "Running make in $(pwd)..."
        make
        log_success "Test code built for $COMPONENT"
    else
        log_warning "No Makefile found in $SAL_WORK_DIR/$COMPONENT/cpp"
        log_info "Checking for executables in subdirectories..."
        
        # For components like MTMount, executables are in topic subdirectories
        local found_executables=false
        if find "$SAL_WORK_DIR" -name "sacpp_${COMPONENT}_*" -type f -executable 2>/dev/null | head -1 | grep -q .; then
            found_executables=true
            log_success "Executables already built during code generation:"
            find "$SAL_WORK_DIR" -name "sacpp_${COMPONENT}_*" -type f -executable 2>/dev/null | head -10
        fi
        
        if [ "$found_executables" = false ]; then
            log_error "No executables found for $COMPONENT"
            log_info "Try running: ./test_setup_stepwise.sh generate $COMPONENT"
            return 1
        fi
    fi
}

# Step 10: Run test producer/consumer
step_run_tests() {
    local COMPONENT=${1:-Test}
    log_info "=== STEP 10: Running Tests for $COMPONENT ==="
    
    source_setup_functions
    setup_environment
    
    log_info "Searching for $COMPONENT executables..."
    
    # Find all executables for this component
    local execs=$(find "$SAL_WORK_DIR" -name "sacpp_${COMPONENT}_*" -type f -executable 2>/dev/null)
    
    if [ -z "$execs" ]; then
        log_error "No executables found for $COMPONENT"
        log_info "Have you run: ./test_setup_stepwise.sh generate $COMPONENT ?"
        return 1
    fi
    
    # Count executables by type
    local cmd_count=$(echo "$execs" | grep -c "_commander$" || true)
    local ctl_count=$(echo "$execs" | grep -c "_controller$" || true)
    local pub_count=$(echo "$execs" | grep -c "_pub$" || true)
    local sub_count=$(echo "$execs" | grep -c "_sub$" || true)
    local send_count=$(echo "$execs" | grep -c "_send$" || true)
    local log_count=$(echo "$execs" | grep -c "_log$" || true)
    
    log_success "Found executables for $COMPONENT:"
    echo "  Commands: $cmd_count commanders, $ctl_count controllers"
    echo "  Events: $send_count senders, $log_count loggers"
    echo "  Telemetry: $pub_count publishers, $sub_count subscribers"
    echo ""
    
    log_info "Example locations:"
    echo "$execs" | head -5
    echo ""
    
    log_info "To test telemetry (publisher/subscriber):"
    local first_pub=$(echo "$execs" | grep "_pub$" | head -1)
    if [ -n "$first_pub" ]; then
        local pub_dir=$(dirname "$first_pub")
        local topic_name=$(basename $(dirname $(dirname "$first_pub")))
        echo "  Terminal 1: cd $pub_dir && ./sacpp_${COMPONENT}_sub"
        echo "  Terminal 2: cd $pub_dir && ./sacpp_${COMPONENT}_pub"
        echo "  (Example for $topic_name)"
    fi
    echo ""
    
    log_info "To test commands:"
    echo "  Find in: $SAL_WORK_DIR/${COMPONENT}_notused/cpp/"
    echo "  Terminal 1: ./sacpp_${COMPONENT}_<command>_controller"
    echo "  Terminal 2: ./sacpp_${COMPONENT}_<command>_commander"
    echo ""
    
    log_info "Don't forget to:"
    echo "  1. Source environment: source /home/saluser/ts_repos/lsst_sdk_install/bin/salenv_complete.sh"
    echo "  2. Create Kafka topics: create_topics $COMPONENT"
    echo "  3. Or use: docker exec broker /opt/kafka/bin/kafka-topics.sh --create ..."
    
    log_success "Test executables ready for $COMPONENT"
}

# Full workflow
run_full_workflow() {
    local COMPONENT=${1:-Test}
    log_info "=== RUNNING FULL WORKFLOW FOR $COMPONENT ==="
    
    step_check_environment
    step_install_system_deps
    step_install_conda_packages
    step_build_avro_c
    step_build_libserdes
    step_setup_environment
    step_verify_installation
    step_generate_sal_code "$COMPONENT"
    step_build_test_code "$COMPONENT"
    step_run_tests "$COMPONENT"
    
    log_success "=== FULL WORKFLOW COMPLETE ==="
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
    check              - Check environment setup (Step 1)
    check-system-deps  - Check if system dependencies are installed
    system-deps        - Install system dependencies (Step 2)
    check-conda-pkgs   - Check if conda packages are installed
    conda-packages     - Install conda packages (Step 3)
    build-avro         - Build Avro C library (Step 4)
    build-avro-cpp     - Build Avro C++ library and avrogencpp tool (Step 4b)
    build-libserdes    - Build libserdes (Step 5)
    setup-env          - Setup environment variables (Step 6)
    verify             - Verify installation (Step 7)
    generate [CSC]     - Generate SAL code for component (Step 8, default: Test)
    build [CSC]        - Build test code (Step 9, default: Test)
    test [CSC]         - Prepare test environment (Step 10, default: Test)
    full [CSC]         - Run complete workflow (default: Test)
    
Examples:
    # Run step by step
    $0 check
    $0 system-deps
    $0 conda-packages
    $0 build-avro
    $0 build-libserdes
    $0 setup-env
    $0 verify
    
    # Generate and test for specific component
    $0 generate MTMount
    $0 build MTMount
    $0 test MTMount
    
    # Run everything at once
    $0 full Test
    $0 full MTMount

EOF
}

# Main command dispatcher
main() {
    local COMMAND=${1:-help}
    shift || true
    
    case "$COMMAND" in
        check)
            step_check_environment
            ;;
        check-system-deps)
            step_check_system_deps
            ;;
        system-deps)
            step_install_system_deps
            ;;
        check-conda-pkgs)
            step_check_conda_packages
            ;;
        conda-packages)
            step_install_conda_packages
            ;;
        build-avro)
            step_build_avro_c
            ;;
        build-avro-cpp)
            step_build_avro_cpp
            ;;
        build-libserdes)
            step_build_libserdes
            ;;
        setup-env)
            step_setup_environment
            ;;
        verify)
            step_verify_installation
            ;;
        generate)
            step_generate_sal_code "$@"
            ;;
        build)
            step_build_test_code "$@"
            ;;
        test)
            step_run_tests "$@"
            ;;
        full)
            run_full_workflow "$@"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            usage
            exit 1
            ;;
    esac
}

# Run main
main "$@"

