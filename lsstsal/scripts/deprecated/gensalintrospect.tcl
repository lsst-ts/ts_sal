#!/usr/bin/env tclsh
## \file gensalintrospect.tcl
# \brief This contains procedures to provide SAL API introspection
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
## Documented proc \c generatetypelists .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generate C++ code for SAL API introspection routines, 
#  getCommandNames, getEventNames, getTelemetryNames
# 
proc generatetypelists { subsys {fout stdout} } {
global env
  set idlfile $env(SAL_WORK_DIR)/idl-templates/validated/sal/sal_[set subsys].idl
  set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
  foreach t $ptypes {
     set id [lindex $t 2]
     if { $id != "command" && $id != "logevent" && $id != "ackcmd" } {
      if { [lindex [split $id _] 0] == "command" } {
        lappend cmds [join [lrange [split $id _] 1 end] _]
      } else {
       if { [lindex [split $id _] 0] == "logevent" } {
          lappend evts [join [lrange [split $id _] 1 end] _]
       } else {
          lappend tlms $id
       }
     }
   }
  }
  puts $fout "
std::vector<std::string> SAL_[set subsys]::getCommandNames()
\{
    std::vector<std::string> it;"
  if { [info exists cmds] } {
   foreach i $cmds {
     puts $fout "    it.push_back(\"$i\");"
   }
  }
  puts $fout "    return it;
\}
"
  puts $fout "
std::vector<std::string> SAL_[set subsys]::getEventNames()
\{
    std::vector<std::string> it;"
  if { [info exists evts] } {
   foreach i $evts {
     puts $fout "    it.push_back(\"$i\");"
   }
  }
  puts $fout "    return it;
\}
"
  puts $fout "
std::vector<std::string> SAL_[set subsys]::getTelemetryNames()
\{
    std::vector<std::string> it;"
  if { [info exists tlms] } {
   foreach i $tlms {
     puts $fout "    it.push_back(\"$i\");"
   }
  }
  puts $fout "    return it;
\}
"
}


