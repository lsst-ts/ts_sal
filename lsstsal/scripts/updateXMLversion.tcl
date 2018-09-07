#!/usr/bin/env tclsh

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


