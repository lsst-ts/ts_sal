#!/usr/bin/env tclsh

#
#  Rebuild per subsystem idl templates from existing definitions
#
set basedir /d2/lsst/streams
source $env(SAL_DIR)/checkidl.tcl


foreach s $subsystems {
   set all [lsort [glob $basedir/[set s]_*.idl]]
   set fout [open idl-templates/template-$s.idl w]
   foreach f $all {
      set fin [open $f r]
      while { [gets $fin rec] > -1 } {
        if { [lindex [split $rec "/"] 2] != "private" } {
           puts $fout $rec
        }
      }
      close $fin
      puts $fout "\n\n\n"
      puts stdout "Processed $f"
   }
   close $fout
}

#
#  Revalidate each individual set
#

cd idl-templates
mkdir -p validated
foreach s $SAL_SUBSYSTEMS {
   checkidl template-$s.idl
   puts stdout "Validated $s"
   exec rm validated/template-$s.idl
}


