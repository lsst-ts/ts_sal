#!/usr/bin/env tclsh
## \file genddspython.tcl
# \brief This contains procedures generate helper files for
#  the DDS native python api CSC's
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
## Documented proc \c enumToPython .
# \param[in] str Convert a SAL XML enumeration name to python compatible
#
proc enumToPython { str } {
  if { [string toupper $str] == $str } {return $str}
  set pieces [regexp -all -inline {[a-z]+|[A-Z][a-z]*} $str]
  set result [string toupper [dojoin $pieces]]
}


#
## Documented proc \c dojoin .
# \param[in] pieces Reformat a SAL XML enumeration name
#
proc dojoin { pieces } {
   set res ""
   set llast 0
   foreach p $pieces { 
      if { [string length $p] > 1 } {
         if { $llast == 1 } {
           set res "[set res][set p]_"
         } else {
           set tres [string trim $res "_"]
           set res "[set tres]_[set p]_"
         }
      } else { 
         set res "[set res]$p"
      }
      set llast [string length $p]
   }
   set res [string trim $res "_"]
}


#
## Documented proc \c ucname .
# \param[in] name Uppercase a SAL XML enumeration name
#
#  Format name as upper case
#
proc ucname { name } {
  set parts [split $name ,]
  set res [toucamcase [lindex $parts 0]][toucamcase [lindex $parts 1]]
}

#
## Documented proc \c toucamcase .
# \param[in] str camelCase a SAL XML enumeration name
#
#  Format name as camelCase
#
proc toucamcase { str } {
   set caps [enumToPython $str]
   set out ""
   foreach x [split $caps _] {
      set out "$out[string totitle $x]"
   }
   return $out
}


#
## Documented proc \c genPythonEnums .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate a set python enumerations for a SAL XML enumeration
#
proc genPythonEnums { subsys } {
global SAL_WORK_DIR EVENT_ENUMS
  if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl] } {
    source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl
    if { [info exists EVENT_ENUMS] } {
      set fout [open $SAL_WORK_DIR/[set subsys]/SAL_[set subsys]_enum.py w]
      puts $fout "import enum"
      foreach i [lsort [array names EVENT_ENUMS]] {
        set idot [join [split $i ,] .]
        puts $fout "class [set subsys][ucname $i](enum.IntEnum):"
        puts $fout "   \"\"\"[set subsys] logevent_[set idot] constants.\"\"\""
        set enums $EVENT_ENUMS($i)
        set iv 1
        foreach v [split $enums ","] {
          if { [llength [split $v "="]] > 1 } {
            set iv [lindex [split $v "="] 1]
            set v [lindex [split $v "="] 0]
          }
          puts $fout "   [enumToPython $v] = $iv"
          incr iv 1
        }
        puts $fout ""
        puts $fout ""
      }
      close $fout
      puts stdout "Python support for enums defined for subsystem $subsys"
    } else { 
      puts stdout "No enums defined for subsystem $subsys"
    }
  }
}

#
## Documented proc \c testPythonEnums .
#
#  Test python generation for all SAL XML enumerations
#
proc testPythonEmums { } {
global SYSDIC
  foreach subsys $SYSDIC(systems) {
    genPythonEnums $subsys
  }
}


set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

source $SAL_DIR/activaterevcodes.tcl
source $SAL_WORK_DIR/idl-templates/validated/[set argv]_revCodes.tcl
source $SAL_WORK_DIR/idl-templates/validated/[set argv]_cmddef.tcl
source $SAL_WORK_DIR/idl-templates/validated/[set argv]_evtdef.tcl
source $SAL_WORK_DIR/idl-templates/validated/[set argv]_tlmdef.tcl
genPythonEnums $argv


