## \file ospl_version.tcl
# \brief Sets the OpenSplice version for use in salgenerator
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code
if { [info exists env(LSST_KAFKA_PREFIX)] == 0 } {
  set OSPL_HDE $env(OSPL_HOME)
  set ospl [lsearch [split $OSPL_HDE) "/"] OpenSpliceDDS]
  set OSPL_VERSION [string trim [lindex [split $OSPL_HDE) "/"]  [expr $ospl +1] ] V]
  set l  [llength [split $OSPL_VERSION .]]
  if { $l == 2 } {set OSPL_VERSION $OSPL_VERSION.0}
  set SIMD_BASE_DIR /opt/simd
  set DDSGEN "$OSPL_HDE/bin/idlpp -I $OSPL_HDE/etc/idl"
} else {
  set OSPL_VERSION 0.0.0
}

