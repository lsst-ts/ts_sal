#!/usr/bin/env tclsh
## \file pythonprint.tcl
# \brief This contains procedures to create and manage the
# MD5SUM revision codes used to uniqely identify versioned
# DDS Topic names.
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
## Documented proc \c pythonprinter .
# \param[in] fout File handle of output python test script
# \param[in] SAL Topic name
#
#  Help routine to generate python code to print SAL Topic data
#
proc pythonprinter { fout topic } {
global TLMS TLM_ALIASES CMDS CMD_ALIASES EVTS EVENT_ALIASES
  set base [split $topic _]
  set subsys [lindex $base 0]
  set alias [getAlias $topic]
  if { $alias != "ackcmd" } {
    if { [lindex $base 1] == "command" } {
      set items $CMDS($subsys,$alias,param)
    } else {
      if { [lindex $base 1] == "logevent" } {
        set items $EVTS($subsys,$alias,param)
      } else {
        set items $TLMS($subsys,$alias,param)
      }
    }
    foreach item $items {
      set id [lindex $item end]
      if { [llength [split $item "()"]] > 1 } {
        set xid [lindex [split $id ()] 0]
        puts $fout "    print(\"$id = \" + str(list(myData.$xid)))"
      } else {
        puts $fout "    print(\"$id = \" + str(myData.$id))"
      }
    }
  }
}

