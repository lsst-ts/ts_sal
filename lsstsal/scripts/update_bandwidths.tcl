#!/usr/bin/env tclsh

set SAL_HOME $env(SAL_HOME)
puts stdout "Rebuilding bandwidth estimates"
source $SAL_HOME/scripts/make_descpubsub.tcl
source $SAL_HOME/scripts/build_datastreams.tcl
source $SAL_HOME/scripts/parse-ds.tcl
source $SAL_HOME/scripts/sid.tcl

source $SAL_HOME/scripts/sal_version.tcl

set all [glob html/salgenerator/*]
foreach s $all {
   if { [file isdirectory $s] } {
     set subsys [file tail $s]
     if { [info exists SID($subsys)] == 0 } {
        puts stdout "No SID for $subsys"
     } else {
       set ssid $SID($subsys)
       set cmd "exec tar cvzf [set ssid]_[set subsys].tgz [glob $s/*-streamdef.html]"
       eval $cmd
     }
   }
}

exec tar cvzf telemetry_bandwidths_[set SALVERSION].tgz bandwidth





