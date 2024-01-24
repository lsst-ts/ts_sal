#!/usr/bin/env tclsh
## \file testAvroCodeGen.tcl
# \brief Test Avro code generation used in SAL suite of programs
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

#
## Documented proc \c salavrogen .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] lang Language to generate code for
#
#  Generate Avro files for a Subsystem/CSC
#
proc testAvroCodeGen { subsys lang } {
global SAL_WORK_DIR AVRO_RELEASE SAL_DIR
      if { $lang == "cpp" } {
          set all [glob $SAL_WORK_DIR/avro-templates/[set subsys]/[set subsys]_*.json]
          foreach i $all {
             puts stdout "Processing $i"
             exec avrogencpp -i $i -o $SAL_WORK_DIR/[set subsys]/cpp/src/[file rootname [file tail $i]].hh
          }
       }
       if { $lang == "java"} {
          set all [glob $SAL_WORK_DIR/avro-templates/[set subsys]/[set subsys]_*.json]
          foreach i $all {
             puts stdout "Processing $i"
             catch {exec java -jar $SAL_DIR/../lib/avro-tools-[set AVRO_RELEASE].jar compile schema $i $SAL_WORK_DIR/[set subsys]/java/src/ }
          }
      }
}

set SAL_WORK_DIR $env(SAL_WORK_DIR)
set SAL_DIR $env(SAL_DIR)
set AVRO_RELEASE $env(AVRO_RELEASE)

