#!/bin/env tclsh
## \file update_ts_xml_dictionary.tcl
# \brief This contains procedures to work woth SALSubsystems.xml
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
## Documented proc \c createSystemDictionary .
# 
#  Create a default basic SALSubsystems.xml
#
proc createSystemDictionary { } {
global env SAL_WORK_DIR
  set fout [open $SAL_WORK_DIR/SALSubsystems.xml w]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $fout "<?xml-stylesheet type=\"text/xsl\" href=\"http://github.com/lsst-ts/ts_xml/tree/master/schema/SALSubsystemSet.xsl\"?>"
  puts $fout "<SALSubsystemSet xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://github.com/lsst-ts/ts_xml/tree/master/schema/SALSubsystemSet.xsd\">
"
  set DONE(SALSubsystems) 1
  set all [lsort [glob $env(SAL_WORK_DIR)/*.xml]]
  foreach i $all {
    set s [lindex [split [file tail $i] "_."] 0]
    if { [info exists DONE($s)] == 0 } {
      set DONE($s) 1
      puts $fout "
<Subsystem>
  <Name>$s</Name>
  <Description></Description
  <Enumeration></Enumeration>
  <Generics>yes</Generics>
  <Author></Author>
</Subsystem>
"
     }
  }
  puts $fout "</SALSubsystems>
"
  close $fout
}

#
## Documented proc \c parseSystemDictionary .
# 
#  Parse the SALSubsystems.tcl and create a SYSDIC array object
#  for use by salgenerator
#
proc parseSystemDictionary { } {
global env SYSDIC SAL_WORK_DIR OPTIONS
  if { $OPTIONS(verbose) } {puts stdout "###TRACE>>> parseSystemDictionary"}
  set SYSDIC(systems) ""
  getValidGenerics
  set fin [open $env(SAL_WORK_DIR)/SALSubsystems.xml r]
  while { [gets $fin rec] > -1 } {
      set tag   [lindex [split $rec "<>"] 1]
      set value [lindex [split $rec "<>"] 2]
      if { $tag == "Name" } {
         set name $value
         lappend SYSDIC(systems) $name
      }
      if { $tag == "Description" } {
         set SYSDIC($name,Description) $value
      }
      if { $tag == "AddedGenerics" } {
         addGenerics $name $value
      }
      if { $tag == "Generics" } {
         puts stdout "
************************************************************************
********** WARNING : Deprecated <Generics> tag found, ignoring *********
************************************************************************"
      }
      if { $tag == "Enumeration" || $tag == "IndexEnumeration" } {
         if { $value != "" && $value != "no" } {
           set ids [split $value ,]
           set SYSDIC($name,keyedID) 1
           set SYSDIC($name,IndexEnumeration) ""
           set idx 1
           foreach i $ids { 
              if { [llength [split $i "="]] > 1 } {
                set idx  [string trim [lindex [split $i "="] 1]]
                set eval [string trim [lindex [split $i "="] 0]]
                set SYSDIC($name,$idx) $eval
                lappend SYSDIC($name,IndexEnumeration) "$idx:$eval"
              } else {
                set SYSDIC($name,$idx) $i
                lappend SYSDIC($name,IndexEnumeration) "$idx:$i"
                incr idx 1
              }
           }
         }
      }
      if { $tag == "RuntimeLanguages" } {
         set langs [split $value ,]
         foreach l $langs {
           if { $OPTIONS(verbose) } {puts stdout "TRACE------ $name needs runtime support for $l"}
           set support [string tolower [string trim $l]]
           set SYSDIC($name,$support) 1
         }
         if { [info exists SYSDIC($name,labview)] } {set SYSDIC($name,cpp) 1}
         if { [info exists SYSDIC($name,salpy)] }  {set SYSDIC($name,cpp) 1}
      }
  } 
  close $fin
  set SYSDIC(systems) [lsort $SYSDIC(systems)]
  if { $OPTIONS(verbose) } {puts stdout "###TRACE<<< parseSystemDictionary"}
}

#
## Documented proc \c getValidGenerics .
#
#  Mark valid generic topics for a Subsystem in SYSDIC
#
proc getValidGenerics { } {
global SAL_WORK_DIR SYSDIC
  set all [split [exec grep EFDB_Topic $SAL_WORK_DIR/SALGenerics.xml] \n]
  foreach g $all {
    set gid [string range [lindex [split $g "<>"]  2] 11 end]
    set SYSDIC(validGeneric,$gid) 1
  }
}


#
## Documented proc \c validateGenerics .
#
#  Check valid generic topics for a Subsystem are referenced in SYSDIC
#
proc validateGenerics { subsys generics } {
global SYSDIC
   foreach g [split $generics ,] {
      set chkg [string trim $g]
      if { [info exists SYSDIC(validGeneric,$chkg)] == 0 } {
         errorexit "Bad Subsystem '$subsys' in SALSubsystems.xml\n***               Unknown generic - $chkg"
      }
   }
}

#
## Documented proc \c addGenerics .
#
#  Process the addedGenerics
#
proc addGenerics { name glist } {
global SYSDIC
  buildGenericCategories
  catch {unset SYSDIC($name,hasAllGenerics)}
  set SYSDIC($name,genericsUsed) $SYSDIC(Category,mandatory)
  if { $glist != "" } {
    foreach t [split $glist ","] {
      if { [info exists SYSDIC(Category,$t)] } {
        set SYSDIC($name,genericsUsed) "$SYSDIC($name,genericsUsed),$SYSDIC(Category,$t)"
      } else {
        set SYSDIC($name,genericsUsed) "$SYSDIC($name,genericsUsed),$t"
      }
    }
  }
}

#
## Documented proc \c buildGenericCategories .
#
#  Build the available Generic topic categories from SALGenerics.xml
#
proc buildGenericCategories { } {
global SYSDIC SAL_WORK_DIR
  set SYSDIC(GenericCategories) ""
  set fcat [open $SAL_WORK_DIR/SALGenerics.xml r]
  while { [gets $fcat rec] > -1 } {
    set tag   [lindex [split $rec "<>"] 1]
    set value [lindex [split $rec "<>"] 2]
    if { $tag == "EFDB_Topic" } {
       set gname [join [lrange [split $value "_"] 1 end] "_"]
    }
    if { $tag == "Category" } {
       if { [lsearch $SYSDIC(GenericCategories) $value] < 0 } {
         lappend SYSDIC(GenericCategories) $value
       }
       lappend SYSDIC(Category,$value) $gname
    }
  }
  close $fcat
  foreach c $SYSDIC(GenericCategories) {
    set SYSDIC(Category,$c) [join $SYSDIC(Category,$c) ","]
  }
}



