#!/usr/bin/env tclsh
## \file processgenerics.tcl
# \brief This contains procedures to create CSC specific Generics.xml
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

source $env(SAL_DIR)/sal_version.tcl

#
## Documented proc \c generategenerics .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate SAL Subsystem/CSC specific XML from the SALGenerics input file
#
proc generategenerics { subsys } {
global SALVERSION SAL_WORK_DIR
  filtergenerics $subsys
  set fout [open /tmp/salgenerics_[set subsys] w]
  puts $fout "perl -pi -w -e 's/SALGeneric/$subsys/g;' $SAL_WORK_DIR/[set subsys]_Generics.xml"
  puts $fout "perl -pi -w -e 's/SALVersion/$SALVERSION/g;' $SAL_WORK_DIR/[set subsys]_Generics.xml"
  close $fout
  exec chmod 755 /tmp/salgenerics_[set subsys]
  exec /tmp/salgenerics_[set subsys]
}

proc filtergenerics { subsys } {
global SALVERSION SYSDIC SAL_WORK_DIR env
  set fin [open $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/SALGenerics.xml r]
  set fout [open $SAL_WORK_DIR/[set subsys]_Generics.xml w]
  gets $fin rec ; puts $fout $rec
  gets $fin rec ; puts $fout $rec
  while { [gets $fin rec] > -1 } {
    set tag   [lindex [split $rec "<>"] 1]
    set value [lindex [split $rec "<>"] 2]
    if { $tag != "SALCommand" && $tag != "SALEvent" } {
      puts $fout $rec
    }
    if { $tag == "SALCommand" } {
       set command ""
       while { $tag != "/SALCommand" } {
         gets $fin rec
         set tag   [lindex [split $rec "<>"] 1]
         set value [lindex [split $rec "<>"] 2]
	 lappend command $rec
	 if { $tag == "EFDB_Topic" } {
	   set generic [join [lrange [split $value "_"] 1 end] "_"]
	   set copyit [lsearch [split $SYSDIC($subsys,genericsUsed) ","] $generic]
	 }
       }
       if { $copyit > -1 } {
          puts stdout "Enabling $generic"
	  puts $fout "    <SALCommand>"
	  foreach l $command {puts $fout $l}
       }
    }
    if { $tag == "SALEvent" } {
       set event ""
       while { $tag != "/SALEvent" } {
         gets $fin rec
         set tag   [lindex [split $rec "<>"] 1]
         set value [lindex [split $rec "<>"] 2]
	 lappend event $rec
	 if { $tag == "EFDB_Topic" } {
	   set generic [join [lrange [split $value "_"] 1 end] "_"]
	   set copyit [lsearch [split $SYSDIC($subsys,genericsUsed) ","] $generic]
	 }
       }
       if { $copyit > -1 } {
          puts stdout "Enabling $generic"
	  puts $fout "    <SALEvent>"
	  foreach l $event {puts $fout $l}
       }
    }
  }
  close $fin
  close $fout
}
