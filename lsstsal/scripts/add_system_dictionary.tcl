#!/usr/bin/env tclsh
## \file add_system_dictionary.tcl
# \brief This contains procedures to calculate MD5 revision codes
# used to uniqely identify versioned DDS Topic names, and to update the
# System dictionary (SYSDIC) array which stores the per-subsystem
# properties.
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
## Documented proc \c calcshmid .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Calculate the MD5 checksum for a file
#
proc calcshmid { subsys } {
  set fout [open /tmp/subsys.tmp w]
  puts $fout "$subsys"
  close $fout
  set id [string range [exec md5sum /tmp/subsys.tmp] 0 3]
  return $id
}

if { [file exists $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/SALSubsystems.xml] } {
   source $env(SAL_DIR)/update_ts_xml_dictionary.tcl
   parseSystemDictionary
} else {
   puts stdout "
*************************************************************************************************
****************** WARNING - missing dictionary *************************************************
*************************************************************************************************

	$env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/SALSubsystems.xml not found

*************************************************************************************************
*************************************************************************************************"

  exit 7
}

set SYSDIC(datatypes) "byte short int long float string int64 double ubyte ushort uint ulong"
