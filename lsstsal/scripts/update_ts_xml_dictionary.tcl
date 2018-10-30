#!/bin/env tclsh

proc createSystemDictionary { } {
global env
  set fout [open SALSubsystems.xml w]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $fout "<?xml-stylesheet type=\"text/xsl\" href=\"http://lsst-sal.tuc.noao.edu/schema/SALSubsystems.xsl\"?>"
  puts $fout "<SALSubsystems xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://lsst-sal.tuc.noao.edu/schema/SALSubsystems.xsd\">
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
  <Version></Version>
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
global env SYSDIC
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
            set SYSDIC($name,hasGenerics) 1
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
  } 
  close $fin
}



