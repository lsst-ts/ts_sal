.. py:currentmodule:: lsst.ts.sal

.. _lsst.ts.sal.version_history:

###############
Version History
###############
Changes for 8.0.0
=================

* Add suppport for Kafka as the middleware transport

Changes for 7.5.0
=================

* Add new ~ based scheme for RPM naming

Changes for 7.4.1
=================

* Add timeout field inclusion for C++ ackCommand's
* Removed references from C++ and Java unit tests

Changes for 7.4.0
=================

* Fix mavenize scripts to use https

Changes for 7.3.0
=================

* Remove git tag from jar naming and respect VERSION= specifier

Changes for 7.2.0
=================

* Rework Java QoS setup to require less code

* Add salIndex to C structs so user code can see it

* Fix update of user visible private_rcvStamp

* Take change in directory structure in ts_xml into account.

Changes for 7.1.0
=================

* Send logevent_authList with empty payload on startup if authList is enabled

Changes for 7.0.0
=================

* Check authList even when no command is in the queue

* Remove priority field from Events

* Replace [subsys]ID with salIndex for multiple instance CSC's

* Use "second" as private_sndStamp and private_rcvStamp units

* Remove deprecated python (boost and pybind11) API generation

* Rename SAL_actors.h to SAL_,CSC._actors.h and add to RPMs

* Remove deprecated IDL_Type tag processing, default is no-limit for strings

* Remove deprecated use of SAL__CMD_ACK as an automatic ack

* LSST_DDS_PARTITION_PREFIX is now set to a random value at the start of each Java unit test.

Changes for 6.1.0
=================

* Add C++ unit tests.

* Add Java unit tests.

* Improve SALPY unit tests.

Changes for 6.0.0
=================

* Add support for LSST_DDS_ENABLE_AUTHLIST environment variable

* Add interlanguage tests for C++ and Java and salobj

* Replace <Generics> with <AddedGenerics> and new selection strategy

* Reset debugLevel=0 for Java

* Add support for single element 1-D arrays for Java

* Rollup single test loops to avoid code-to-large Java errors

* Add authList support for C++/SALPY/Java/LabVIEW CSC's

* Add Per CSC API documentation for C++/SALPY/Java/LabVIEW/IDL

* Fix missing programs in test RPM's

* Fix missing jar in RPM's

* Fix getSAL/XML/OSPLVersion for LabVIEW

* Remove LSST_DDS_DOMAIN references

* Add lsst.io compatible version history

* Fix Jenkinfile

* Cross link cpp/java api docs to ts_xml.lsst.io

* Change getXXXVersion's to static for C++

Changes for 5.1.2
=================

* Hotfix to populate missing private field values for Java ackcmd

Changes for 5.1.1
=================

* Hotfix to restore missing sacpp_xxxx_types.so to runtime RPMs


Changes for 5.1.0
=================

* Increase max string size for LabVIEW and allow unlimited string size
  for strings with unspecified length for other languages

* Fix python environment for V3.8.3

* Remove LSST_DDS_PARTITION_PREFIX default

* Add pause after DDS participant creation

* Add support to get software versions in LabVIEW

* Add support for static SAL libraries

* Improve SAL error reporting in the event of missing system components

* Change QoS.xml location to ts_ddsconfig/qos/QoS.xml

* Better reporting for "Unknown topic"

Changes for 5.0.1
=================

* Added level 2 debug to LabVIEW interfaces

* Fix SALGenerics.xml parsing


Changes for 5.0.0
=================

* Add historySync to Java and call wait_for_history

* Add DDS QOS definition using the ts_idl/qos/QoS.xml file

* Remove deprecated QOS related code (option to use DDS defaults)

* Add support for per CSC partition names

* Add tuning configuration to the DDS ospl.xml system configuration

* Add private fields to LabVIEW ctl's

* Remove unused files

* Do not call history sync if LSST_DDS_HISTORYSYNC < 0

* Update rpm naming scheme

* Make debug output available only in higher debug level

* Fix XML version in runtimes for getXMLVersion

* Add getOSPLVersion for runtimes

* Test runtime builds in CentOS 8 environment

* Generate rpm/deb for Raspberry pi 4 (Raspian and CentOS 7)

* Add support for authList in the topic private data

* Add support for authList by adding SAL contructors that specify identity


Changes for 4.1.4
=================

* Hot fix to support changes to SALSubsystems.xml (IndexEnumeration tag)

* Copy XML VERSION from TS_XML_DIR

Changes for 4.1.3
=================

* Hotfix to allow building in the LSST stack environment
  using old compilers and libraries (provide CLOCK_TAI define)

Changes for 4.1
=================

* Allow commands with no arguments

* Allow subsystems with no commands

* Add asset checking and exit on errors to salgenerator

* Remove redundant files

* Add  support for retreiving timestamp metadata in SALPY

* Remove redundant metadata from topics

* Add a salgenerator command that only generates the revision coded idl

* Add a check for string length exceptions in C++/SALPY

* Add support for subscriber/publisher existance checking

* Add support for routine entry/exit tracking in verbose mode of salgenerator

* Add support for adding SAL_VERSION and XML_VERSION to idl

* Add support for passing Unit and Description metadata to pydds via idl

* Update RPM's to be relocatable where possible

* Add seperate log files for each rpm build

* Update default ospl.xml to allow unlimited participants per node


Changes for 4.0.0
=================

* Add support for RPI4 platform build

* Add support for setting Enumeration values to use defined values

* Add exception generation when null data structures passed to SAL methods

* Support for using the Opensplice QoS specified in an XML file
  specified using environment e.g. export LSST_DDS_QOS=file://${SAL_WORK_DIR}/DDS_DefaultQoS_All.xml

* Added fields to ackcmd structure for host, origin, cmdtype and timeout

* Added revCode to ackcmd on-the-wire DDS topics

* Added support to pass host IP using environment e.g. export LSST_DDS_IP=10.0.100.1

* Changed default DURABILITY to VOLATILE for commands and acks

* Changed default history depth to 100 in code and QoS XML

* Added support for customizing generic commands and events in SALSubsystems.xml

* Added support for inserting PTP timestamps, and a daemon to maintain the leap seconds offset
  (added call to retrieve current offset)

* Add  JNI library for Java timestamps

* Add units and descriptions to the autogenerated HTML object tables

* Add more exit codes to salgenerator

* Add getLastSample to C++ and SALPY API's

* Fix bugs in Java all-in-one test generators

* Revised SAL item database to be single table per subystem

* Add environment to control history sync e.g. export LSST_DDS_HISTORYSYNC=30
  (set default to 30 seconds)

* Revised salgenerator pydds option to generate enum support

* Remove deprecated parts of API


Changes for 3.9.0
=================

* Support for OpenSplice V6.9

* EFD writers for Kafka and InfluxDB

* RPM generation

* Increased build and test efficiency

* Upgrade to pybind11 wrapper


Changes for 3.8.0
=================

* Add SAL__STATE_ defines for generic states

* Add support for Python OO library

* Move CSC dictionary to ts_xml/sal_interfaces/SALSubsystems.xml and change to XML format

* Remove generic Commands/Events from generated MagicDraw XMI importable

* Change location of Nexus repository

Changes for 3.7.2
=================

* Update CSC list

* Remove rougue setup file

Changes for 3.7.1
=================

* Please refer to the SAL User Guide for installation instructions.

* Fixed java commanders to include an origin field (temporarily a default)

* Fixed SQL table generator string handling

* Improved runtime generator scripts

* Reduced unit test time

* Fixed LabVIEW command/response issues

* Added missing pybind11 wrappers

* Added generic UML generator with Magic Draw support

* Moved checkStatus into SAL classes

* Added tuneableQos support to java api

* Cleaned up c++ with/without python library build

* Changed generated Makefiles to use SAL_WORK_DIR for libraries

* Speed up maven CI by ommitting no-value tests


Changes for 3.7.0
=================

* Added support for Enumerations, either per item , or globally
  (code support in C++,Java,Python,LabVIEW)

* Bug fixes for Java code generation.

* Add support for pybind11 based python wrappers. Boost::Python support
  is now deprecated and will be removed in version 4.0.0

* Add support for LargeFileObject announcment events

* Update SAL User Guide

* Add support for automatic creation of EFD writer processes.

* Add script to automate updating of https://project.lsst.org/ts/sal_objects website

* Fix LabVIEW Event handling

* Add new CSC's for headerService's, ecc, summitFacility, atcs, vms

* Add monitorCommand method for LabVIEW API

* Upgrade Event Junit tests

* Bug fixes for LabVIEW Monitor process

* Add minimal Telemetry generation to  XML parser

* Default to adding generic Commands and Events in XML parser if not preset in
  incoming XML files (temporary exception for m1m3 to use non-compliant generic command set)



Release 3.6 deprecated - do not use
===================================

Changes for 3.5.2
=================

* New CSC's for Auxillary Telesope (accs) and instrumentation
* Default to Python3 compatability
* Enumeration support in XML and downstream
*

Changes for 3.5.1
=================

* Provide compatability with the LSST OpenSpliceDDS 6.7 release
  (salgenerator now avoids hardcoding the OpenSplice release number into the maven project generator)

Changes for 3.5.0
=================

* The LabVIEW interface is now based on passing Cluster datatypes which should make
  it easier to use. The VI generation process is a little more involved, so please refer to
  the updated user guide (chapter 9) for more information.

* The LabVIEW shared memory Monitor has been upgraded to support multiple (50) simulataneous
  LabVIEW connections per machine and subsystem (due to this change, calling shmRelease prior
  to application exit is now mandatory).

* Removed sample XML object definition files to avoid confusion of versions. The definitive XML
  should always be retreived from the LSST Stash ts_xml repository.

* The Python interface has been modified to incorporate control of the Global Interpreter Lock
  (GIL) to allow the DDS threads sufficient cpu time under high load conditions.

* Added new commandable subsystems for DM (archiver, catchuparchiver, and processingcluster)
  and OCS (sequencer).

* Added salgenerator error detection for "no language" selected when using sal code generation.

* Added hooks for per-topic QoS tuning control in future.

* Added bandwidth documentation updater

* Enhanced SAL object table html format table output

* Added LABVIEW_HOME environment variable to permit user control

* Added LSST_DDS_DOMAIN environment variable to allow DDS partitioning to
  isolate users when testing on the same network.



Changes for 3.4.0
=================

* Added generic Event types

* Added Java controller tests

* Added m2ms Telemetry items

* Added ocs commands


Changes for 3.3.0
=================

* Add Dome commandable sub-systems for the major elements

Changes for 3.2.1
=================

* Passed comprehensive Continuous Integration Python tests

* Added LSST_[subsystem]_ID environment variable to select required instance
  of subsytem at runtime (used for hexapod and rotator currently)

* The Python interface has been modified to incorporate control of the Global Interpreter Lock
  (GIL) to allow the DDS threads sufficient cpu time under high load conditions.

Changes for 3.2.0
=================

* Passed initial Continuous Integration Python tests

Changes for 3.1.1
=================

* Added SWIG based code generation option.

* Passed Continuous Integration C++ tests
