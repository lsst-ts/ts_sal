.. _lsst.ts.sal.env_variables:

====================================
SAL Environment Variables Reference
====================================

This document explains the key environment variables used throughout the SAL (Service Abstraction Layer) build and runtime system.

.. contents:: Table of Contents
   :local:
   :depth: 2

Core Variables
==============

LSST_SDK_INSTALL
----------------

- **Purpose**: Points to the ts_sal repository root directory
- **Typical value**: ``/home/saluser/repos/ts_sal``
- **Contains**: SAL scripts, tools, source code (bin/, lsstsal/, etc.)
- **Used for**: Finding salgenerator, SAL scripts, templates
- **Relationship**: Always equals ``TS_SAL_DIR``

LSST_SAL_PREFIX
---------------

- **Purpose**: Installation prefix for libraries and headers
- **Typical values**: 

  - ``$CONDA_PREFIX`` (preferred) - e.g., ``/opt/lsst/software/stack/conda/envs/lsst-scipipe-10.1.0``
  - ``$LSST_SDK_INSTALL`` (fallback if conda not writable)

- **Contains**: Built libraries (libavro, libserdes, librdkafka) and their headers
- **Decision logic**: Uses conda env if writable, else ts_sal repo
- **Used for**: Where to install/find built dependencies
- **Key insight**: Determines whether dependencies are added to the conda environment (e.g. jenkinsfile) or ts_sal repo (e.g. development)

TS_SAL_DIR
----------

- **Purpose**: Historical alias for ``LSST_SDK_INSTALL``
- **Typical value**: Same as ``LSST_SDK_INSTALL``
- **Why both exist**: Different parts of the codebase use different names
- **Relationship**: Always ``TS_SAL_DIR == LSST_SDK_INSTALL``

SAL_HOME
--------

- **Purpose**: Points to the lsstsal subdirectory within ts_sal
- **Formula**: ``$LSST_SDK_INSTALL/lsstsal``
- **Typical value**: ``/home/saluser/repos/ts_sal/lsstsal``
- **Contains**: SAL runtime scripts, salenv.sh, utilities
- **Relationship**: Always derived from ``LSST_SDK_INSTALL``

SAL_WORK_DIR
------------

- **Purpose**: Working directory for code generation output
- **Typical values**:

  - **CI/Jenkins**: ``$LSST_SDK_INSTALL/test`` (uses repo's test directory)
  - **Development**: ``/tmp/sal_work`` or ``$LSST_SDK_INSTALL/sal_work``

- **Contains**: Generated C++/Java code, Makefiles, executables, avro-templates/
- **CRITICAL**: Should NOT point to ``ts_sal/test`` when developing! (see ts_sal/test/README)
- **Key insight**: Different between CI and development workflows

TS_XML_DIR
----------

- **Purpose**: Points to the ts_xml repository root
- **Typical value**: ``/home/saluser/repos/ts_xml``
- **Contains**: XML schema definitions for all SAL components (MTMount, Test, Script, etc.)
- **Used for**: Finding component XML definitions during code generation
- **Common pattern**: Usually a sibling directory to ts_sal

Relationship Summary
====================

.. code-block:: text

   When variables are the SAME:
     TS_SAL_DIR == LSST_SDK_INSTALL           (always)
     SAL_HOME == $LSST_SDK_INSTALL/lsstsal    (always)

   When variables DIFFER:
     LSST_SAL_PREFIX:
       - In conda env: /opt/lsst/software/stack/conda/envs/lsst-scipipe-10.1.0
       - Fallback: /home/saluser/repos/ts_sal
     
     SAL_WORK_DIR:
       - CI/Jenkins: /home/saluser/repos/ts_sal/test
       - Development: /tmp/sal_work

Typical Configurations
======================

CI/Jenkins Environment
----------------------

.. code-block:: bash

   LSST_SDK_INSTALL=/home/saluser/repos/ts_sal
   LSST_SAL_PREFIX=$CONDA_PREFIX                     # Usually conda env
   TS_SAL_DIR=/home/saluser/repos/ts_sal              # Same as LSST_SDK_INSTALL
   SAL_HOME=/home/saluser/repos/ts_sal/lsstsal        # Derived
   SAL_WORK_DIR=/home/saluser/repos/ts_sal/test       # Uses repo test dir
   TS_XML_DIR=/home/saluser/repos/ts_xml              # Sibling repo

Development Environment
-----------------------

.. code-block:: bash

   LSST_SDK_INSTALL=/home/saluser/ts_repos/ts_sal
   LSST_SAL_PREFIX=$CONDA_PREFIX                      # Usually conda env
   TS_SAL_DIR=/home/saluser/ts_repos/ts_sal           # Same as LSST_SDK_INSTALL
   SAL_HOME=/home/saluser/ts_repos/ts_sal/lsstsal     # Derived
   SAL_WORK_DIR=/tmp/sal_work                         # DIFFERENT! Avoids repo pollution
   TS_XML_DIR=/home/saluser/ts_repos/ts_xml           # Sibling repo

Additional Variables
====================

Build Tool Versions
-------------------

- ``MAVEN_RELEASE``, ``AVRO_RELEASE``, ``BOOST_RELEASE``, ``JDK_RELEASE``
- ``KAFKA_RELEASE``, ``JACKSON_RELEASE``, ``LIBRDKAFKA_RELEASE``
- Used by: Build scripts to download/use specific versions

Avro-specific
-------------

- ``AVRO_HOME``: ``$LSST_SAL_PREFIX/lib`` (where Avro libraries live)
- ``AVRO_INCL``: ``$LSST_SAL_PREFIX/include/avro`` (where Avro headers live)
- ``AVRO_CLASSPATH``: ``lsst/$LSST_TOPIC_SUBNAME`` (Java classpath for Avro)

Kafka-specific
--------------

See ``salenv_kafka.sh`` for details:

- ``LSST_KAFKA_IP``, ``LSST_SCHEMA_REGISTRY_URL``
- ``LSST_KAFKA_BROKER_ADDR``
- Connection and broker configuration for Kafka cluster

LSST_TOPIC_SUBNAME (CRITICAL - Required!)
------------------------------------------

- **Purpose**: Determines the Avro namespace and Kafka topic prefix
- **Used by**: 

  - **ts_salobj (Python)**: Required by ``create_topics``, ``Domain``, ``Remote``, and all SAL components
  - **ts_sal (C++ code generation)**: Used by ``getAvroNamespace()`` in TCL scripts

- **Typical values**:

  - ``sal`` - Production/default namespace (topics: ``lsst.sal.Component.topic``)
  - ``test`` - CI/testing namespace (topics: ``lsst.test.Component.topic``)
  - Custom - Development/isolated testing (topics: ``lsst.{custom}.Component.topic``)

- **How it works** (CURRENT BEHAVIOR):

  - **ALL values** use format: ``lsst.{LSST_TOPIC_SUBNAME}.``
  - If ``LSST_TOPIC_SUBNAME=sal`` → namespace is ``lsst.sal.``
  - If ``LSST_TOPIC_SUBNAME=test`` → namespace is ``lsst.test.``
  - Any other value → namespace is ``lsst.{value}.``
  - **Changed**: Previously only "sal" used ``lsst.sal.`` format, others used ``{value}_`` format
  - **Reason**: Ensures C++ (ts_sal) and Python (ts_salobj) use identical topic names

- **Critical**: MUST be set before running any SAL code (Python or C++)
- **Why it exists**: Allows multiple environments (prod, test, dev) to coexist on same Kafka cluster without topic name collisions
- **Compatibility**: Ensures ts_salobj (Python) and ts_sal (C++) create matching topic names

LSST_KAFKA_PREFIX (DEPRECATED - Legacy only)
---------------------------------------------

.. warning::
   **Legacy/Deprecated** - appears in old templates but not actively used

- **Found in**: Old Java template code (``SALKAFKA.java.template``)
- **Modern replacement**: Use ``LSST_TOPIC_SUBNAME`` instead
- **Historical purpose**: Was intended to add runtime topic prefix in DDS-to-Kafka transition
- **Current recommendation**: Set to ``sal`` for backward compatibility, but rely on ``LSST_TOPIC_SUBNAME`` for actual topic naming

Topic Naming Summary
---------------------

.. code-block:: text

   OLD (deprecated): lsst.ts.sal.{LSST_KAFKA_PREFIX}.{topicName}  ❌ Not used

   CURRENT FORMAT:   lsst.{LSST_TOPIC_SUBNAME}.{Component}.{topic} ✅ Use this

   Examples:
     LSST_TOPIC_SUBNAME=sal    → lsst.sal.MTMount.azimuth
     LSST_TOPIC_SUBNAME=test   → lsst.test.MTMount.azimuth
     LSST_TOPIC_SUBNAME=mytest → lsst.mytest.MTMount.azimuth

   Note: ALL values now use the lsst.{subname}. format for consistency
         between C++ (ts_sal) and Python (ts_salobj) components.

Historical Behavior (Pre-Nov-2025 Code)
========================================

.. warning::
   If you encounter unexpected topic names, you may be running old code.

**Old behavior**: Only ``sal`` used ``lsst.sal.`` prefix; other values used ``{value}_`` prefix:

- ``LSST_TOPIC_SUBNAME=sal`` → ``lsst.sal.MTMount.azimuth`` ✓
- ``LSST_TOPIC_SUBNAME=test`` → ``test_MTMount.azimuth`` ⚠️ (no lsst prefix!)

**Problem**: Python (ts_salobj) always used ``lsst.{subname}.`` format, causing C++/Python topic name mismatches.

**Symptoms**: Components can't communicate between C++ and Python when using non-"sal" subnames.

**Fix**: Update ``checkjson.tcl`` proc ``getAvroNamespace`` to: ``return "lsst.[set LSST_TOPIC_SUBNAME]."``

Common Issues
=============

"avrogencpp not found"
----------------------

**Cause**: ``$LSST_SAL_PREFIX/bin`` not in PATH

**Solution**: Ensure PATH includes ``${LSST_SAL_PREFIX}/bin:${TS_SAL_DIR}/bin``

"libserdes/serdescpp-avro.h not found"
--------------------------------------

**Cause**: libserdes headers not in ``$LSST_SAL_PREFIX/include/libserdes/``

**Solution**: Run setup script to install headers, or check ``CPLUS_INCLUDE_PATH``

"Cannot find libraries at link time"
-------------------------------------

**Cause**: Libraries not in ``$LSST_SAL_PREFIX/lib/`` or ``LD_LIBRARY_PATH`` not set

**Solution**: Verify libraries are installed and ``LD_LIBRARY_PATH`` includes ``$LSST_SAL_PREFIX/lib``

"Working directory does not exist"
-----------------------------------

**Cause**: ``SAL_WORK_DIR`` not created or pointing to non-existent directory

**Solution**: ``mkdir -p $SAL_WORK_DIR``

Verification Commands
=====================

.. code-block:: bash

   # Check all key variables
   echo "LSST_SDK_INSTALL: $LSST_SDK_INSTALL"
   echo "LSST_SAL_PREFIX:  $LSST_SAL_PREFIX"
   echo "TS_SAL_DIR:       $TS_SAL_DIR"
   echo "SAL_HOME:         $SAL_HOME"
   echo "SAL_WORK_DIR:     $SAL_WORK_DIR"
   echo "TS_XML_DIR:       $TS_XML_DIR"

   # Verify directories exist
   for dir in "$LSST_SDK_INSTALL" "$LSST_SAL_PREFIX" "$SAL_HOME" "$SAL_WORK_DIR" "$TS_XML_DIR"; do
     if [ -d "$dir" ]; then
       echo "✓ $dir exists"
     else
       echo "✗ $dir NOT FOUND"
     fi
   done

   # Check for critical tools
   which salgenerator avrogencpp conda cmake g++

   # Check for critical libraries
   ls -l $LSST_SAL_PREFIX/lib/libavro* $LSST_SAL_PREFIX/lib/libserdes* $LSST_SAL_PREFIX/lib/librdkafka*

Related Files
=============

- ``salenv_paths.sh`` - Sets all core path variables
- ``salenv_kafka.sh`` - Sets Kafka-specific variables
- ``salenv_complete.sh`` - Sources both and provides verification
- ``setup_stack_build.sh`` - Setup script that builds all dependencies
- ``setup_persistent_local.sh`` - Setup script for persistent local builds
