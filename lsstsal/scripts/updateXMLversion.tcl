#!/usr/bin/env tclsh
## \file updateXMLversion.tcl
# \brief This contains a script to change VERSION tags in SAL XML
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
cd /data/gitrepo/ts_xml/sal_interfaces
set all [glob */*.xml]
foreach i $all {
   puts stdout "Updating $i"
   set fin [open $i r]
   set fout [open /tmp/update.xml w]
   while { [gets $fin rec] > -1 } {
      if { [lindex [split $rec "<>"] 1] == "Version" } {
        puts $fout "<Version>$SALVERSION</Version>"
      } else {
        puts $fout $rec
      }
   }
   close $fin
   close $fout
   exec mv /tmp/update.xml $i
}


