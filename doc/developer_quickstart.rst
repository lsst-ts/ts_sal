.. _lsst.ts.sal.developer_quickstart:

================================
SAL Developer Quickstart Guide
================================

This guide explains how to test and develop SAL code locally, replicating both the Jenkins CI pipeline and a persistent development environment.

.. contents:: Table of Contents
   :local:
   :depth: 2

Prerequisites
=============

Required Services
-----------------

- **Kafka Cluster**: Must be running before any SAL code can execute
- **Schema Registry**: Part of the Kafka stack, required for Avro serialization

Starting Kafka Services
------------------------

.. code-block:: bash

   # Start Kafka and related services
   docker compose -f <path_to>/ts_salobj/docker-compose.yaml up -d

   # To stop them
   docker compose -f <path_to>/ts_salobj/docker-compose.yaml rm --stop --force

Docker Images
-------------

- **CI/Jenkins testing**: ``lsstts/salobj:develop`` (includes conda environment, LSST stack)
- **Development**: ``lsstts/develop-env:develop`` (includes conda environment, build tools)

Jenkins-like CI Build
=====================

This workflow replicates what runs in the Jenkins CI pipeline. Use this to test changes before submitting a PR.

Overview
--------

- **Image**: ``lsstts/salobj:develop``
- **Script**: ``bin/jenkinsfile_ci_test_build.sh``
- **Build Target**: Conda environment (``LSST_SAL_PREFIX=$CONDA_PREFIX``)
- **Working Directory**: ``test/`` (within the ts_sal repo)
- **Topic Namespace**: ``test`` (to avoid collisions with production)
- **Duration**: ~5-10 minutes (no Avro C++ build from source)

Step-by-Step
------------

Terminal 1: Run the CI Build Script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Start the container with network access to Kafka
   docker run -it --rm \
     --network kafka \
     --name "sal_ci_test" \
     -p 8888:8888 \
     -v /path/to/your/workspace:/home/saluser/ts_repos \
     lsstts/salobj:develop

   # Inside the container
   cd ~/repos/ts_sal

   # Optional: if you're testing local changes not yet in the container
   # for file in `cat ~/ts_repos/ts_sal/copyto.txt`; do 
   #   cp -p ~/ts_repos/ts_sal/$file $file
   # done

   # Create the working directory
   mkdir -p sal_work
   export SAL_WORK_DIR=$(pwd)/sal_work

   # Run the CI-like build script
   ./bin/jenkinsfile_ci_test_build.sh

**What this does**:

1. Sources the LSST stack environment (``~/.setup.sh``)
2. Builds dependencies (Avro C, libserdes) into the conda environment
3. Generates SAL code for ``Test`` and ``Script`` components
4. Compiles and runs C++ unit tests
5. Compiles and runs Java camera tests (if ``simple_sal`` repo is available)



Terminal 2: Generate SAL Code, Create Topics and Run Subscriber
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Connect to the same running container
   docker exec -ti sal_ci_test /bin/bash

   cd ~/repos/ts_sal

   # Set up the full SAL environment
   export LSST_SDK_INSTALL=$(pwd)
   export LSST_SAL_PREFIX=$CONDA_PREFIX
   export SAL_WORK_DIR=$(pwd)/sal_work
   export LSST_TOPIC_SUBNAME=test
   source ./bin/salenv_complete.sh

   # Generate SAL code for a component (e.g., MTMount)
   salgeneratorKafka MTMount validate
   salgeneratorKafka MTMount sal cpp

   # Create Kafka topics
   # Note: create_topics requires the FULL environment (salenv_complete.sh)
   #       and will use the namespace set in LSST_TOPIC_SUBNAME
   create_topics MTMount

   # Run the subscriber
   ./sal_work/MTMount_azimuth/cpp/standalone/sacpp_MTMount_sub


Terminal 1 (continued): Run a Publisher
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Set up minimal Kafka environment (SAL env was only in the 
   #  script jenkinsfile_ci_test_build.sh, but not the terminal)
   export LSST_TOPIC_SUBNAME=test
   source ./bin/salenv_kafka.sh

   # Run the publisher
   ./sal_work/MTMount_azimuth/cpp/standalone/sacpp_MTMount_pub


Persistent Development Environment
===================================

This workflow is for active development where you want built artifacts (like ``avrogencpp``, ``libserdes``) to persist across container restarts.

Overview
--------

- **Image**: ``lsstts/develop-env:develop``
- **Script**: ``bin/setup_persistent_local.sh``
- **Build Target**: ``ts_sal/local/`` directory (mounted, survives restarts)
- **Working Directory**: ``sal_work/`` (within the ts_sal repo, also survives restarts)
- **Topic Namespace**: ``test`` (default)
- **Duration**: ~30-45 minutes first time (builds Avro C++ from source), ~1 minute on subsequent runs

Key Difference
--------------

Unlike the Jenkins workflow, this builds dependencies into ``ts_sal/local/`` instead of the conda environment. 

**Critical distinction**: The ts_sal repository is on your **local machine** and mounted into the container at ``~/ts_repos/ts_sal``. In contrast, the Jenkins workflow uses ``~/repos/ts_sal`` which exists only inside the container (not mounted). Since your local filesystem is mounted, all artifacts in ``ts_sal/local/`` and ``ts_sal/sal_work/`` **persist across container restarts**.

Step-by-Step
------------

Terminal 1: Initial Setup, Build and Create Topics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Start the container with your local ts_sal mounted
   docker run -it --rm \
     --network kafka \
     --name "sal_dev_env" \
     -p 8888:8888 \
     -v /path/to/your/workspace:/home/saluser/ts_repos \
     lsstts/develop-env:develop

   # Inside the container, navigate to your mounted ts_sal
   cd ~/ts_repos/ts_sal

   # Run the persistent setup script
   # WARNING: First run builds Avro C++ from source, which can take 20+ minutes.
   # The script will appear to hang at:
   #   "[ 87%] Building CXX object CMakeFiles/AvrogencppTests.dir/test/AvrogencppTests.cc.o"
   # This is normal! Just wait.
   source ./bin/setup_persistent_local.sh

   # Create Kafka topics (environment is already set from setup script)
   create_topics MTMount

**What this does**:

1. Creates ``ts_sal/local/{bin,lib,include}`` directories
2. Builds Avro C, Avro C++, libserdes, Catch2 from source
3. Installs everything to ``ts_sal/local/`` (which persists on your host)
4. Sets up the full SAL environment (equivalent to ``salenv_complete.sh``)
5. Defaults ``LSST_TOPIC_SUBNAME=test``

.. note::
   **After the first run**: The built artifacts are on your host filesystem. Subsequent container sessions can skip the build and just activate the environment (see below).


Terminal 2: Activate Environment and Generate Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Connect to the same running container
   docker exec -ti sal_dev_env /bin/bash

   cd ~/ts_repos/ts_sal

   # Activate the persistent local environment
   # (This is fast - just sets env vars, no building)
   source bin/activate_local_environment.sh

   # Generate SAL code
   salgeneratorKafka MTMount validate
   salgeneratorKafka MTMount sal cpp

   # Run a subscriber
   ./sal_work/MTMount_azimuth/cpp/standalone/sacpp_MTMount_sub


Terminal 1 (continued): Run Publisher and Check Output in Subscriber
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   # Run a publisher and check the output in the subscriber terminal
   ./sal_work/MTMount_azimuth/cpp/standalone/sacpp_MTMount_pub

Terminal 2: Activate Environment and Generate Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Subsequent Container Sessions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you restart the container, you don't need to rebuild:

.. code-block:: bash

   # Start container with the same mount
   docker run -it --rm --network kafka \
     --name "sal_dev_env" \
     -v /path/to/your/workspace:/home/saluser/ts_repos \
     lsstts/develop-env:develop

   cd ~/ts_repos/ts_sal

   # Just activate the environment (built artifacts are already there)
   source bin/activate_local_environment.sh

   # Continue working...
   salgeneratorKafka MTMount sal cpp

Understanding the Two Workflows
================================

Jenkins-like CI Build
---------------------

**When to use**: Testing changes before submitting a PR, replicating CI failures locally

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Aspect
     - Value
   * - Docker Image
     - ``lsstts/salobj:develop``
   * - Install Prefix
     - ``$CONDA_PREFIX`` (ephemeral conda env)
   * - Working Dir
     - ``test/`` (in repo)
   * - Persistence
     - ❌ Lost on container restart
   * - Build Time
     - ~5-10 min
   * - Use Case
     - Pre-PR testing, CI debugging
   * - Avro C++ Source
     - ❌ Uses pre-installed conda package

Persistent Development
----------------------

**When to use**: Active development, iterating on SAL code changes

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Aspect
     - Value
   * - Docker Image
     - ``lsstts/develop-env:develop``
   * - Install Prefix
     - ``ts_sal/local/`` (on host filesystem)
   * - Working Dir
     - ``sal_work/`` (in repo)
   * - Persistence
     - ✅ Survives container restarts
   * - Build Time
     - ~30-45 min first time, ~1 min after
   * - Use Case
     - Development, iteration
   * - Avro C++ Source
     - ✅ Builds from source (includes ``avrogencpp``)

Key Environment Variables
--------------------------

Both workflows set these variables, but differently:

.. code-block:: bash

   # Jenkins-like CI
   LSST_SDK_INSTALL=~/repos/ts_sal
   LSST_SAL_PREFIX=$CONDA_PREFIX              # e.g., /opt/lsst/.../lsst-scipipe-10.1.0
   SAL_WORK_DIR=~/repos/ts_sal/test
   LSST_TOPIC_SUBNAME=test

   # Persistent Development
   LSST_SDK_INSTALL=~/ts_repos/ts_sal
   LSST_SAL_PREFIX=~/ts_repos/ts_sal/local    # Persistent on host!
   SAL_WORK_DIR=~/ts_repos/ts_sal/sal_work
   LSST_TOPIC_SUBNAME=test                     # Default

See :doc:`sal_env_variables` for detailed explanations.

Common Tasks
============

Generate SAL Code for a Component
----------------------------------

.. code-block:: bash

   # Full SAL environment must be set (use salenv_complete.sh or activate script)
   export LSST_TOPIC_SUBNAME=test  # or 'sal' for production
   source bin/salenv_complete.sh

   # Validate XML definitions
   salgeneratorKafka <Component> validate

   # Generate C++ code
   salgeneratorKafka <Component> sal cpp

   # Generate Java code
   salgeneratorKafka <Component> sal java

   # Build shared library
   salgeneratorKafka <Component> lib

   # Build Maven project
   salgeneratorKafka <Component> maven

Create Kafka Topics
--------------------

.. code-block:: bash

   # Requires FULL environment (not just salenv_kafka.sh)
   export LSST_TOPIC_SUBNAME=test
   source bin/salenv_complete.sh

   # Topics will be created with prefix lsst.test.<Component>.<topic>
   create_topics <Component>

Run Generated Executables
--------------------------

.. code-block:: bash

   # Minimal Kafka environment is sufficient
   export LSST_TOPIC_SUBNAME=test
   source bin/salenv_kafka.sh

   # Navigate to the standalone directory
   cd $SAL_WORK_DIR/<Component>_<topic>/cpp/standalone

   # Run subscriber or publisher
   ./sacpp_<Component>_sub
   ./sacpp_<Component>_pub

Clean and Rebuild
------------------

.. code-block:: bash

   # Remove generated code
   rm -rf $SAL_WORK_DIR/<Component>*

   # Remove C++ test artifacts
   cd cpp_tests
   make clean

   # Rebuild persistent local environment (if needed)
   cd ~/ts_repos/ts_sal
   source bin/setup_persistent_local.sh

Troubleshooting
===============

"avrogencpp: command not found"
--------------------------------

**Cause**: ``avrogencpp`` not built or not in PATH

**Solution**:

.. code-block:: bash

   # For persistent dev: rebuild from source
   source bin/setup_persistent_local.sh

   # For Jenkins-like: ensure conda package is installed
   conda install -c conda-forge avro-cpp
   export PATH=$LSST_SAL_PREFIX/bin:$PATH

"cannot find -lCatch2Main"
---------------------------

**Cause**: Catch2 not installed in the expected location

**Solution**:

.. code-block:: bash

   # Persistent dev: reinstall Catch2
   source bin/setup_persistent_local.sh

   # Jenkins-like: check conda env
   conda list | grep catch2

"libserdes/serdescpp-avro.h: No such file or directory"
-------------------------------------------------------

**Cause**: libserdes C++ headers not installed

**Solution**:

.. code-block:: bash

   # Verify installation
   ls -l $LSST_SAL_PREFIX/include/libserdes/

   # Reinstall if missing
   source bin/setup_stack_build.sh  # Jenkins-like
   # OR
   source bin/setup_persistent_local.sh  # Persistent dev

"Working directory $SAL_WORK_DIR does not exist"
-------------------------------------------------

**Cause**: ``SAL_WORK_DIR`` not set or directory not created

**Solution**:

.. code-block:: bash

   export SAL_WORK_DIR=$(pwd)/sal_work
   mkdir -p $SAL_WORK_DIR

C++ and Python Components Can't Communicate
--------------------------------------------

**Cause**: Topic name mismatch (different ``LSST_TOPIC_SUBNAME`` values)

**Solution**:

.. code-block:: bash

   # Ensure BOTH sides use the same subname
   export LSST_TOPIC_SUBNAME=test

   # Verify topic names match
   # C++ topics: lsst.test.Component.topic
   # Python topics: lsst.test.Component.topic

   # If using old code, topics may differ:
   # C++ (old): test_Component.topic  ❌
   # Python: lsst.test.Component.topic ✅
   # Fix: Update ts_sal/lsstsal/scripts/checkjson.tcl to latest version

"x86_64-conda-linux-gnu-cpp: fatal error: '-c' is not a valid option"
----------------------------------------------------------------------

**Cause**: ``CPP`` variable is set to the C preprocessor instead of the C++ compiler in the CI environment

**Solution**: This should be fixed in the latest code (Makefile uses ``CXX`` instead of ``CPP``). If you still see this:

.. code-block:: bash

   # Verify Makefile uses CXX
   grep "^CXX" cpp_tests/Makefile  # Should see: CXX ?= g++ ...

   # Pull latest changes
   git pull origin <branch>

Kafka Connection Errors
------------------------

**Cause**: Kafka services not running or wrong network

**Solution**:

.. code-block:: bash

   # Check Kafka is running
   docker ps | grep kafka

   # Restart Kafka services
   docker compose -f <path_to>/ts_salobj/docker-compose.yaml up -d

   # Ensure container is on the kafka network
   docker run --network kafka ...  # ← critical flag

"Permission denied" when installing to conda
---------------------------------------------

**Cause**: Conda environment is read-only (common in CI images)

**Solution**: The scripts should auto-detect this and fall back to installing in ``ts_sal/local/`` or ``ts_sal/``. If not:

.. code-block:: bash

   export LSST_SAL_PREFIX=$(pwd)/local
   source bin/setup_persistent_local.sh

Quick Reference Scripts
=======================

Setup Scripts
-------------

- ``bin/setup_stack_build.sh`` - Build dependencies into conda env (Jenkins-like)
- ``bin/setup_persistent_local.sh`` - Build dependencies into ts_sal/local/ (persistent)
- ``bin/activate_local_environment.sh`` - Activate persistent local env (fast)

Environment Scripts
-------------------

- ``bin/salenv_complete.sh`` - Full SAL environment (paths + Kafka)
- ``bin/salenv_paths.sh`` - Core SAL paths only
- ``bin/salenv_kafka.sh`` - Kafka configuration only

Build/Test Scripts
------------------

- ``bin/jenkinsfile_ci_test_build.sh`` - Replicate Jenkins CI pipeline locally

Helper Scripts
--------------

- ``bin/salgeneratorKafka`` - Main SAL code generation tool
- ``lsstsal/scripts/create_topics`` - Create Kafka topics (requires ts_salobj)

Additional Resources
====================

- :doc:`sal_env_variables` - Detailed explanation of all environment variables
- :doc:`sal_user_guide` - Complete SAL user guide
- :doc:`introduction` - SAL architecture and concepts
- **ts_salobj Documentation** - Python SAL API reference
