#!/usr/bin/env tclsh 

set scriptdir $SAL_DIR

source $scriptdir/datastream_desc.tcl
source $scriptdir/camera-subsysdesc.tcl
source $scriptdir/unitsdesc.tcl
source $scriptdir/qosdesc.tcl

set last ""
set fck [open $SAL_WORK_DIR/.salwork/datastreams.detail r]
while { [gets $fck rec] > -1 } {
   set d [split [lindex $rec 0] "./"]
   set id [join [lrange $d 0 [expr [llength $d]-2]] .]
   set system [lindex $d 0]
   set topic [join [lrange $d 0 [expr [llength $d]-2]] .]
   if { $id != $last  } {
      if { [info exists DESC($id)] == 0 } {
          puts stdout "No DESC for $id"
          if { [info exists SDESC($id)] == 0 } {
             puts stdout "No SDESC for $id"
             set DESC($id) "TBD"
             set SDESC($id) "TBD"
          } else {
             set DESC($id) $SDESC($id)
          }
      } else {
          if { [info exists SDESC($id)] == 0 } {
             set SDESC($id) $DESC($id)
          }
      }
      set last $id
   }
}
close $fck


