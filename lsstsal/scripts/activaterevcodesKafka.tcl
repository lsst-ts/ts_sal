#!/usr/bin/env tclsh
## \file activaterevcodesKafka.tcl
# \brief This contains procedures to create and manage the
# MD5SUM revision codes used to uniqely identify versioned
# AVRO Topic schema names.
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

set SAL_WORK_DIR $env(SAL_WORK_DIR)
#
## Documented proc \c updateRevCodes .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Create the file avro-templates/SUBSYSTEM_revCodes.tcl
#  which can be used to create a REVCODE array containing all the codes
#  for a particular Subsystem/CSC
#
proc updateRevCodes { subsys } {
global SAL_WORK_DIR REVCODE
  set ljson [glob $SAL_WORK_DIR/avro-templates/[set subsys]/[set subsys]_*.json]
  set fmd5 [open $SAL_WORK_DIR/avro-templates/[set subsys]_revCodes.tcl w]
  foreach i [lsort $ljson] {
    set c [lindex [exec md5sum $i] 0]
    set s [file tail [file rootname $i]]
    puts $fmd5 "set REVCODE($s) [string range $c 0 7]"
    set REVCODE($s) [string range $c 0 7]
  }
  close $fmd5
}


## Documented proc \c getItemName .
# \param[in] rec An input record, typically from an Avro json file
#
#  Take an input json line and determine the name of an item
#
proc getItemName { rec } {
  set r2 [lindex [split $rec "\":,"] 4]
  return $item
}


## Documented proc \c activeRevCodes .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Parse an input Avro json file and generate the revision code assets.
#  Also creates the Metadata annotations for Unit and Description
#
#  These consist of :
#    revCodes - avro-templates/sal/sal_revCoded_SUBSYSTEM.json
#
proc activeRevCodes { subsys } {
global SAL_WORK_DIR REVCODE OPTIONS SALVERSION METADATA XMLVERSION
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> activeRevCodes $subsys"}
  set fin [open $SAL_WORK_DIR/avro-templates/sal/sal_[set subsys].json r]
  set fout [open $SAL_WORK_DIR/avro-templates/sal/sal_revCoded_[set subsys].json w]
  set xmlversion $XMLVERSION
  puts $fout "// SAL_VERSION=$SALVERSION XML_VERSION=$xmlversion"
  gets $fin rec ; puts $fout $rec
  while { [gets $fin rec] > -1 } {
    set r2 [string trim $rec "{}"]
    set r3 [string trim $rec " 	{};"]
    if { $r3 == "" } {
      puts $fout $rec
    } else {
     if { [lindex $r2 0] == "struct" } {
       set curtopic [set subsys]_[lindex $r2 1]
       set id [lindex $r2 1]
       set desc $METADATA([set subsys]_[lindex $r2 1],description)
         set annot " // @Metadata=(Description=\"$desc\")"
         puts $fout "struct [set id]_[string range [set REVCODE([set subsys]_$id)] 0 7] \{ $annot"
     } else {
       if { [lindex $r2 0] == "#pragma" } {
          set id [lindex $r2 2]
          if { $id != "command" && $id != "logevent" } {
            puts $fout "#pragma keylist [set id]_[string range [set REVCODE([set subsys]_$id)] 0 7] [lrange $rec 3 end]"
          } else {
            puts $fout $rec
          }
       } else {
          set annot ""
            if { [lindex [lindex $rec 0] 0] != "const" } {
              set item [getItemName $rec]
              if { $item == "salIndex" } {
                set annot " // @Metadata=(Units=\"unitless\",Description=\"Index number for CSC with multiple instances\")"
                set mu "unitless"
              } else {
                set mn [string trim $curtopic ";"]
                set mu $METADATA($mn,$item,units)
                set md $METADATA($mn,$item,description)
                set annot " // @Metadata=(Units=\"$mu\",Description=\"$md\")"
              }
            }
          if { [string range $annot 0 2] != " //" } { set annot "" }
          puts $fout "$rec[set annot]"
       }
     }
    }
  }
  close $fin
  close $fout
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< activeRevCodes $subsys"}
}


## Documented proc \c getRevCode .
# \param[in] topic Basic name of an Avro Topic schema
# \param[in] type Optional format of MD5 (long=32 char, short=8)
#
#  This routine returns the revision code (MD5) of a named Avro Topic schema
#
proc getRevCode { topic { type "long"} } {
global REVCODE
   if { [llength [split $topic _]] == 2 } {
      set it [lindex [split $topic _] end]
      if { $it == "command" || $it == "logevent" } {
         return ""
      }
   }
   if { $type == "short" } {
     set revcode _[string range [set REVCODE($topic)] 0 7]
   } else {
     set revcode $REVCODE($topic)
   }
   return $revcode
}

## Documented proc \c modJsonForJava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Creates a copy of the Subsystem/CSC Avro json file which is compatible 
#  with the Java option of the Avro code generator tool.
#
proc modJsonForJava { subsys } {
global SAL_WORK_DIR REVCODE SYSDIC CMD_ALIASES OPTIONS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> modJsonForJava $subsys"}
  stdlog "Updating $subsys json with revCodes"
  set lc [exec wc -l $SAL_WORK_DIR/avro-templates/sal/sal_[set subsys].json]
  set lcnt [expr [lindex $lc 0] -2]
  set fin [open $SAL_WORK_DIR/avro-templates/sal/sal_[set subsys].json r]
  exec rm -f $SAL_WORK_DIR/[set subsys]/java/sal_[set subsys].json
  set fout [open $SAL_WORK_DIR/[set subsys]/java/sal_[set subsys].json w]
  set ln 0
  while { $ln < $lcnt} {
     gets $fin rec ; puts $fout $rec
     incr ln 1
  }
  close $fin
  set fin [open $SAL_WORK_DIR/avro-templates/sal/sal_revCoded_[set subsys].json r]
  gets $fin rec; gets $fin rec
  set done 0
  while { [gets $fin rec] > -1 } {
     set chk [lindex [split $rec "\{\}\""] 0]
     if { [lindex  $chk 0] != "const" } {
        puts $fout $rec
     }
  }
  close $fin
  close $fout
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< modJsonForJava $subsys"}
}





