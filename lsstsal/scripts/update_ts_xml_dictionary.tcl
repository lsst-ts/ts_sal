#!/bin/env tclsh

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
      if { $tag == "Generics" } {
         if { $value == "yes" } {
            set SYSDIC($name,hasAllGenerics) 1
         } else {
            if { [llength [split $value ,]] > 1 } {
               validateGenerics $name $value
               if { $OPTIONS(verbose) } {puts stdout "TRACE------ $name has generics $value"}
               set SYSDIC($name,hasGenerics) 1
               set SYSDIC($name,genericsUsed) $value
            }
         }
      }
      if { $tag == "Enumeration" } {
         if { $value != "" } {
           set ids [split $value ,]
           set SYSDIC($name,keyedID) 1
           set idx 1
           foreach i $ids { 
              set SYSDIC($name,$idx) $i
              incr idx 1
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
      }
  } 
  close $fin
  set SYSDIC(systems) [lsort $SYSDIC(systems)]
  if { $OPTIONS(verbose) } {puts stdout "###TRACE<<< parseSystemDictionary"}
}

proc getValidGenerics { } {
global SAL_WORK_DIR SYSDIC
  set all [split [exec grep EFDB_Topic $SAL_WORK_DIR/SALGenerics.xml] \n]
  foreach g $all {
    set gid [string range [lindex [split $g "<>"]  2] 11 end]
    set SYSDIC(validGeneric,$gid) 1
  }
}


proc validateGenerics { subsys generics } {
global SYSDIC
   foreach g [split $generics ,] {
      set chkg [string trim $g]
      if { [info exists SYSDIC(validGeneric,$chkg)] == 0 } {
         errorexit "Bad Subsystem '$subsys' in SALSubsystems.xml\n***               Unknown generic - $chkg"
      }
   }
}



