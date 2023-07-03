#!/usr/bin/env tclsh
## \file streamutilsKafka.tcl
# \brief This contains procedures to create and manage the
# MD5SUM revision codes used to uniqely identify versioned
# Kafka Topic names.
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
## Documented proc \c doitem .
# \param[in] i Index counter
# \param[in] fid File handle of input file
# \param[in] name Name of item
# \param[in] n Dimension of item
# \param[in] type Data type
# \param[in] unit Units specifier
# \param[in] range Range allowed
# \param[in] help Description of item
#
#  Create HTML for SAL Topic item
#
proc doitem { i fid name n type {unit none} {range none} {help "No comment"} } {
   set iname [getitemname $name]
   puts $fid "<TR><TD><INPUT NAME=\"id$i\" VALUE=\"$iname\"></TD>
<TD><select name=\"type$i\">"
   set ctype [lindex [split $type "<>"] 0]
##puts stdout "doitem $i $fid $name $n $ctype $unit $range"
   dotypeselect $fid $ctype
   puts $fid "</select>"
   puts $fid "<TD><INPUT NAME=\"siz$i\" VALUE=\"$n\"></TD>"
   dounit $fid $i $unit
   puts $fid "<TD><INPUT NAME=\"range$i\" VALUE=\"$range\"></TD>
<TD><INPUT NAME=\"help$i\" VALUE=\"$help\"></TD>
<TD><INPUT TYPE=\"checkbox\" NAME=\"delete_$i\" VALUE=\"yes\"></TD></TR>"
}

#
## Documented proc \c dotypeselect .
# \param[in] fid File handle of input file
# \param[in] choice Default selection
# 
# Generate HTML selection
#
proc dotypeselect { fid choice } {
global SYSDIC
   foreach t $SYSDIC(datatypes) {
     if { $t == $choice } {
       puts $fid "<option value=\"$t\" SELECTED>$t</option>"
     } else {
       puts $fid "<option value=\"$t\">$t</option>"
     }
   }
}


#
## Documented proc \c getitemname .
# \param[in] name Name of item
#
#  Return bare item name
#
proc getitemname { name } {
  set spl [split $name "._-"]
  set id [join [lrange $spl 2 end] _]
  return $id
}


#
## Documented proc \c liststreams .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate a file listing all the SAL Topic items
#
proc liststreams { {subsys all} } {
global SAL_WORK_DIR SAL_DIR
   set fs [open $SAL_WORK_DIR/.salwork/datastreams.names r]
   while { [gets $fs rec] > -1 } {
      set spl [split $rec "_"]
      if { $subsys == "all" || $subsys == [lindex $spl 0] } {
        if { [lindex $spl 1] != "command" &&  [lindex $spl 1] != "ackcmd" && [lindex $spl 1] != "logevent"} {
          set s [lindex $spl 0].[join [lrange $spl 1 end] "_"]
          set sname($s) 1
        }
      }
   } 
   return [lsort [array names sname]]  
}


#
## Documented proc \c dounit .
# \param[in] fid File handle of input file
# \param[in] id Name of item
# \param[in] u Units specifier
#
#  Generate a unit selection for HTML interface
#
proc dounit { fid id u} {
global UDESC
  set u [string tolower $u]
  if { [string trim $u] == "" } {set u none}
  puts $fid "<TD><select name=\"unit$id\">"
  puts $fid "<option value=\"$u\" selected>$u"
  foreach i [lsort [array names UDESC]] {
     if { $u != $i } {
       puts $fid "<option value=\"$i\">$i"
     }
  }
  puts $fid "</select></TD>"
}

#
## Documented proc \c dogen .
# \param[in] fid File handle of input file
# \param[in] id Name of item
# \param[in] cmd Optional specifier for Commands
#  Generate checkbox for HTML interface
#
proc dogen { fid id {cmd yes} } {
   if { $cmd } {
      puts $fid "<TR><TD><A HREF=\"sal-generator-$id.html\">$id</A></TD>"
   } else {
      set uid [join [split $id .] "_"]
      puts $fid "<TR><TD><A HREF=\"$id/$uid-streamdef.html\">$id</A></TD>"
   }
   puts $fid "<TD><INPUT TYPE=\"checkbox\" NAME=\"sub_$id\" VALUE=\"yes\">
<TD><INPUT TYPE=\"checkbox\" NAME=\"pub_$id\" VALUE=\"yes\">"
   if { $cmd } {
      puts $fid "<TD><INPUT TYPE=\"checkbox\" NAME=\"issue_$id\" VALUE=\"yes\">
<TD><INPUT TYPE=\"checkbox\" NAME=\"proc_$id\" VALUE=\"yes\">"
   }
}


#
## Documented proc \c jsonpreamble .
# \param[in] fid File handle of input file
# \param[in] id Name of item
#
#  Generate the Json preamble for a SAL Topic
#
proc jsonpreamble { fid id } {
  set subsys [lindex [split $id "_"] 0]
  set name [join [lrange [split $id "_"] 1 end] "_"]
  puts $fid "  \{
 \"type\": \"record\", \"name\": \"[set name]\", \"namespace\": \"lsst.sal.kafka_[set subsys]\", \"fields\": \["
  add_private_json $fid
}

#
## Documented proc \c sqlpreamble .
# \param[in] fid File handle of input file
# \param[in] id Name of item
#
#  Generate the SQL preamble for a SAL Topic
#
proc sqlpreamble { fid id } {
  puts $fid  "CREATE TABLE $id \{"
  puts $fid  "  date_time date time NOT NULL,
  private_revCode char(8),
  private_sndStamp double,
  private_rcvStamp double,
  private_seqNum int,
  private_identity varchar,
  private_origin int,"
}

set WORKING /home/shared/lsst/tests/api/streams
if { [info exists FormData(workingDir)] } {
   set WORKING $FormData(workingDir)
}
if { [info exists env(workingDir)] } {
   set WORKING $env(workingDir)
}

source $env(SAL_DIR)/add_private_json.tcl

